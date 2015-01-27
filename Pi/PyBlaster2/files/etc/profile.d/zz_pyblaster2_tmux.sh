#!/bin/bash


[ -r /etc/default/pyblaster2 ] && . /etc/default/pyblaster2

if [ "$PYBLASTER_RUN_TMUX" = 1 ]; then
  if [ "x$TERM" = "xlinux" ]; then
    if [ ! -f /tmp/.pyblaster-tmux-launched ]; then
      if [ `/opt/vc/bin/tvservice -s | grep -c 'NTSC\|PAL'` = 0 ]; then
        touch /tmp/.pyblaster-tmux-launched
        /opt/PyBlaster2/bin/pyblaster2-tmux.sh
      fi
    fi
  fi
fi
