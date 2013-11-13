#!/bin/bash
#

application="vk"

topdir="/home/admin"
appdir="${topdir}/${application}"
current_path="${appdir}/current"
shared_path="${appdir}/shared"

. "${topdir}/vk/current/bin/vk_env.sh"


if [ -z "$RBENV_SHELL" ] ; then
  PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH:/usr/local/sbin:/usr/local/bin:$HOME/bin"; export PATH
  eval "$(rbenv init -)"
fi


#BUNDLE_GEMFILE="${current_path}/Gemfile"

pidfile="${appdir}/shared/pids/${application}_app_master.pid"
old_pidfile="${pidfile}.old"

UNICORN_CONF="${appdir}/current/config/unicorn-prod.rb"


# Deploy style changes
QUICKMODE=false # Toggling this to true enables you to 'not care' if a deploy is successful.
hot_time_max=480
hot_restart_time=0
extra_quick_sleep=5
report_time=0

# Declare bash arrays
# Positions array is to keep track of the starting
# positions (think line count) of the log files.
positions=()

# Array of the unicorn log files.
log_files=(
  ${shared_path}/log/unicorn.log
  ${shared_path}/log/unicorn.stderr.log
  ${shared_path}/log/unicorn.stdout.log
)


# Ensure that we are not running as the root user.
# If not, error exit while notifying the user.
if [[ $(id -u) -eq 0 ]] ; then
  echo "ERROR: This script must be run as a user, not as root." 2>&1
  exit 1
fi

cd "${appdir}/current"

########################################################

unicorn_is_in_gemfile()
{
  if [[ -s "${current_path}/Gemfile" ]] ; then

    if ! grep -q unicorn "${current_path}/Gemfile" ; then

      printf "\nWarning:
  Unicorn gem not specified in Gemfile, deploy action will
  fail please add the Unicorn gem to your Gemfile like below
  gem 'unicorn', '1.1.5'\n"
      return 1

    fi
  fi

  return 0
}

# Linux
unicorn_is_running()
{
  if [ -f ${pidfile} ] ; then
    fetch_current_pid
    if [[ -d "/proc/${master_pid}" ]] ; then
      return 0
    fi
    rm -f "${pidfile}"
  fi
  return 1
}

# FreebSD
unicorn_is_running_on_freebsd()
{
  if [ -f ${pidfile} ] ; then
    fetch_current_pid

    if [[ -d "/proc/${master_pid}" ]] ; then

      if grep -q --binary-files=text "ruby: unicorn master -E production -c ${appdir}/current/config/unicorn-prod.rb -D" "/proc/${master_pid}/cmdline" ; then
        return 0 # The only valid case, the process is indeed running.
      else
        echo rm -f "$pidfile" # cleanup, aisle 3
      fi

    fi
  fi
  return 1
}


fix_permissions()
{
  # The follow line fails on FreeBSD. And since we're not using it
  # comment it out. But keep it around just in case we need it later
  #
  # find "${shared_path}/log/" -exec sudo chown -R "${user}:${group}" {} \;

  # the function needs at least one executable stmt to avoid an error
  /bin/true
}

# Loop over the unicorn log files array
# ensuring the file exists and
# record the file length into the positions
# array.
record_logfile_positions()
{
  local file

  positions=()
  for file in "${log_files[@]}"
  do
    if [[ ! -f "$file" ]] ; then 
      touch "$file"
    fi
    ## positions+=($(stat -f %z "${file}"))  ## FreeBSD
    positions+=($(stat -c %s "${file}"))  ## Linux
  done
}

# Loop over the unicorn log files array
# and output all changes since the
# starting log positions (length) recorded
# at the beginning of this script.
display_logs()
{
  for (( index=0 ; index < ${#log_files[@]} ; index++ ))
  do
    tail -c +${positions[${index}]} "${log_files[${index}]}"
  done
}

fetch_current_pid()
{
  if [[ -s "$pidfile" ]] ; then
    master_pid=$(cat "$pidfile")
  else
    master_pid=0
  fi
  return 0
}

fetch_new_pid()
{
  if [[ -s "$pidfile" ]] ; then
    new_pid=$(cat "$pidfile")
  else
    new_pid=0
  fi
  return 0
}

old_pidfile_exists()
{
  if [[ -f "$old_pidfile" ]] ; then
    return 0
  else
    return 1
  fi
}

old_master_is_alive()
{
   if old_pidfile_exists ; then
     return 0
   else
     return 1
   fi
}

wait_for_old_master_to_die()
{
  while old_master_is_alive ; do
    sleep .25
    let "hot_restart_time+=1"

    if (( $hot_restart_time >= $hot_time_max )); then
      echo "ERROR: restarting the old unicorn master ($old_master_pid) timed out"
      echo "ERROR: Unicorn has failed to reload properly after $((hot_time_max/4)) seconds."
      echo "original pid: $old_master_pid - new pid: $new_pid"
      return 1
    fi

    fetch_new_pid

    printf '.'
  done

  return 0
}

one_last_check() {
  fetch_new_pid

  # if new master is old master
  if [[ $new_pid -eq $old_master_pid ]] ; then
    display_logs
    echo ""
    echo "ERROR: Unicorn has failed to reload properly."
    echo "original pid: $old_master_pid - new pid: $new_pid"
    return 1
  else
    echo "Completed!"
    return 0
  fi
}

extra_checks() {
  # Let's wait for the old master pid to exit.
  sleep 2
  # It should take more than 2 seconds to start a new process to start and have the pid files swap.
  if old_pidfile_exists ; then
    old_master_pid=$(cat "$old_pidfile")

    if wait_for_old_master_to_die ; then
      sleep $extra_quick_sleep
      one_last_check
      return $?
    else
      return 1
    fi
  else
    # Restart happened too quickly, so it probably failed, or the new master is still the old master.
    echo "NOTICE: Unicorn appers to have reloaded faster then then this script expected which was 2 seconds."
    return 0
  fi
}

deploy_action() {
  # Determine if we have a Gemfile, do we have Unicorn in it.  If so we can do a hot restart.
  if unicorn_is_in_gemfile ; then
    fetch_current_pid
    echo "Signaling Unicorn master (${master_pid}) an hot restart."
    kill -USR2 $master_pid
    # Signal the Unicorn master to do an hot restart by sending the USR2 signal.

    if [ $QUICKMODE = 'false' ]; then
      extra_checks
      return $?
    else
      # extra checks disabled
      echo "NOTICE: extra unicorn checks are not running."
      return 0
    fi
  else
    # Customer has a Gemfile but it does not include the Unicorn gem in it, so we cannot hot restart, we will now manually restart unicorn.
    echo "ERROR/NOTICE: Unicorn is not in the Gemfile properly so we cannot hot restart Unicorn, manually restarting!"
    unicorn_terminate
    sleep 2
    unicorn_start
    return 1
  fi
}

unicorn_start() {
  if ! unicorn_is_running ; then
    printf "Unicorn Starting, App Name: ${application}..."
    bundle exec unicorn -E $RAILS_ENV -c $UNICORN_CONF -D >> /tmp/foo2
    unicorn_status=$?
    if [ ${unicorn_status} == "1" ] ; then
      display_logs
      echo "There was a problem starting unicorn displaying log files:"
      exit 1
    fi
    fetch_current_pid
    echo "  started with pid: ${master_pid}" 
  else
    printf "\nUnicorn master is already running with master_pid: $master_pid"
    return 0
  fi
}

unicorn_status()
{
  if unicorn_is_running ; then
    echo "Unicorn master is running with pid: $master_pid"
  else
    echo "Unicorn master is not running."
  fi
}

unicorn_terminate()
{
  if unicorn_is_running ; then
    echo "Stopping Unicorn for $application with pid $master_pid."

    kill -TERM "$master_pid"
  else
    printf "Unicorn master is not running."
  fi

  return 0
}

unicorn_genocide()
{
  if unicorn_is_running ; then
    echo "WARNING: This is about to kill the master pid with a -9 signal, "
    echo "and then attempt to clean up /all/ unicorn_rails workers."
    echo "If you have multiple applications this may have impacting results."
    echo "This is your final warning, you have 5 seconds before I do damage."

    sleep 5

    echo "Force killing unicorn master $master_pid."

    kill -9 $master_pid && sleep 1

    echo "Thinning the herd."

    if [[ -s "$current_path/config.ru" ]] ; then
      pkill -9 -f 'unicorn' && sleep 1
    else
      pkill -9 -f 'unicorn_rails' && sleep 1
    fi

    rm -f "$pidfile"
  else
    printf "\nUnicorn master not found, nothing to do."
  fi

  return 0
}


record_logfile_positions

case "$1" in

  status)
  unicorn_status
  ;;
start)
  fix_permissions
  unicorn_start
  ;;
stop)
  unicorn_terminate
  ;;
kill)
  unicorn_genocide
  ;;
reload)
  if unicorn_is_running ; then
    fix_permissions
    unicorn_terminate
    sleep 2
    unicorn_start
  else
    echo "Unicorn master not found, starting unicorn."
    unicorn_start
  fi
  ;;
deploy)
  if unicorn_is_running ; then
    fix_permissions
    deploy_action
  else
    unicorn_start
  fi
  ;;
restart)
  if unicorn_is_running ; then
    fix_permissions
    unicorn_terminate
    sleep 2
    unicorn_start
  else
    unicorn_start
  fi
  ;;
  *)
  echo "Usage: $0 {status|start|stop|kill|restart|reload|deploy}"
  exit 1
  ;;
esac

exit 0
