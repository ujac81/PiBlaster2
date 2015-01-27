#!/bin/bash

NAME=pyblaster2
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

DAEMON=/usr/bin/pyblaster2
DAEMON_ARGS="-f -c ${PYBLASTER_CONF}"

# Just to be sure -- should not happen, but who knows...
sudo service pyblaster2 stop
sudo killall pyblaster2

echo 1 > /tmp/pyblaster_respawn

do_poweroff=0
setterm -blank 0

(while [ "`cat /tmp/pyblaster_respawn`" = 1 ]; do

  sudo $DAEMON $DAEMON_ARGS || \
  {
    exit_code=$?
    [ $exit_code -eq 10 ] && \
    {
      echo 0 > /tmp/pyblaster_respawn
      do_poweroff=1
      break
    }
    [ "$PYBLASTER_TERMINAL_MODE" = 1 ] && \
    {
      echo
      echo "!!!!! PyBlaster died !!!!!"
      echo "Restarting in $PYBLASTER_AUTO_RESPAWN_TIMEOUT secs, do 'service pyblaster stop' to prevent respawn."
    }
    sleep $PYBLASTER_AUTO_RESPAWN_TIMEOUT
  }
  sleep 1
done
rm /tmp/pyblaster_respawn
[ $do_poweroff -eq 1 ] && sudo /sbin/poweroff)&
