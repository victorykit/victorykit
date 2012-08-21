while true
  status = `curl --head -s act.watchdog.net | awk 'NR==1{print $2}'`
  if status.strip != '200'
    10.times {`say hey idiots, the site is broken`}
  end
  print "Received #{status} from act.watchdog.net\r"
  $stdout.flush
  sleep 60
end