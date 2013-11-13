#!/bin/bash
# sidekiq    Init script for Sidekiq
#
# Description: Starts and Stops Sidekiq
#

application="vk"

topdir="/home/admin"
appdir="${topdir}/${application}"
current_path="${appdir}/current"
shared_path="${appdir}/shared"

log_file="${current_path}/log/sidekiq.log"
lock_file="${current_path}/log/${application}_sidekiq.lock"
pid_file="${current_path}/pids/${application}_sidekiq.pid"


. "${topdir}/vk/current/bin/vk_env.sh"


if [ -z "$RBENV_SHELL" ] ; then
  PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH:/usr/local/sbin:/usr/local/bin:$HOME/bin"; export PATH
  eval "$(rbenv init -)"
fi


START_CMD="${current_path}/bin/vk_run.sh sidekiq -P $pid_file"
RETVAL=0


# Ensure that we are not running as the root user.
# If not, error exit while notifying the user.
if [[ $(id -u) -eq 0 ]] ; then
  echo "ERROR: This script must be run as a user, not as root." 2>&1
  exit 1
fi

cd "${applicationdir}/current"


status()
{
  ps -ef | egrep 'sidekiq [0-9]+.[0-9]+.[0-9]+' | grep -v grep
  return $?
}

start()
{
  status
  if [ $? -eq 1 ]; then
    echo "Starting sidekiq .. "
    $START_CMD >> $log_file 2>&1 &
    RETVAL=$?
    #Sleeping for 8 seconds for process to be precisely visible in process table - See status ()
    sleep 8
    [ $RETVAL -eq 0 ] && touch $lock_file
    return $RETVAL
  else
    echo "sidekiq is already running .. "
  fi


}

stop() {

    echo "Stopping sidekiq .."
    SIG="INT"
    kill -$SIG `cat  $pid_file`
    RETVAL=$?
    [ $RETVAL -eq 0 ] && rm -f $lock_file
    return $RETVAL
}



case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status

        if [ $? -eq 0 ]; then
             echo "sidekiq is running .."
             RETVAL=0
         else
             echo "sidekiq is stopped .."
             RETVAL=1
         fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 0
        ;;
esac
exit $RETVAL
