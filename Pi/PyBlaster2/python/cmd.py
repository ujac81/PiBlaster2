"""cmd.py -- Evaluate commands received via RFCOMM, Lirc or Buttons

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

from codes import *

import gpio
import log


STATUSOK = 0            # evaluation successful
ERRORPARSE = 1          # failed to read command
ERRORUNKNOWN = 2        # unknown command
ERRORARGS = 3           # wrong number or wrong type of args
ERROREVAL = 4           # evaluation did not succeed,
                        # because called function failed

STATUSEXIT = 100        # tell calling instance to close comm/pipe/whatever
STATUSDISCONNECT = 101  # tell calling instance to close comm/pipe/whatever


class Cmd:
    """ Evaluate commands reveived via RFCOMM or pipe"""

    def __init__(self, main):
        """ Set in/out fifos to None"""

        self.main = main

    def eval(self, cmdline, src='Unknown', payload=None):
        """Evaluate command and perform action

        Called by RFCommServer, Lirc or Buttons

        :returns [status, code, status_msg, result_list]
        """
        cmdline = cmdline.strip()
        line = cmdline.split()
        line = [s.replace("_", " ") for s in line]
        cmd = ""
        if line:
            cmd = line[0]

        int_args = []
        for args in line:
            try:
                intarg = int(args)
                int_args.append(intarg)
            except TypeError:
                int_args.append(None)
            except ValueError:
                int_args.append(None)

        ret_stat = STATUSOK
        ret_msg = "OK"
        ret_code = -1
        ret_list = []

        if payload is None:
            payload = []

        self.main.log.write(log.MESSAGE,
                            "Eval cmd [%s]: %s; payload size: %d" %
                            (src, " || ".join(line), len(payload)))

        # # # EVAL CMD # # #

        # Command evaluation, in alphabetical order.
        # If ret_code is unchanged, unknown command is assumed.

        if cmd == "disconnect":
            ret_stat = STATUSDISCONNECT
            ret_code = CON_DISCONNECT

        if cmd == "equalstatus":
            ret_code = EQUAL_STATUS
            if self.main.alsa.has_equalizer():
                chans = self.main.alsa.equal_channels
                vals = ["%d" % i for i in self.main.alsa.get_equal_vals()]
                ret_list = [vals, chans]

        if cmd == "keepalive":
            ret_code = KEEP_ALIVE

        if cmd == "playlistinfocurrent":
            ret_code = PLAYLIST_INFO
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "playlistinfocurrent requires 1 int arg"
            else:
                ret_list = self.main.mpc.playlistinfo_current(int_args[1])
                ret_msg = self.main.mpc.get_status_string('song')

        if cmd == "playlistinfo":
            ret_code = PLAYLIST_INFO
            if len(line) != 3 or int_args[1] is None or int_args[2] is None:
                ret_stat = ERRORARGS
                ret_msg = "playlistinfo requires 2 int args"
            else:
                ret_list = self.main.mpc.playlistinfo(int_args[1], int_args[2])
                ret_msg = self.main.mpc.get_status_string('song')

        if cmd == "playnext":
            ret_code = PLAY_NEXT
            self.main.mpc.next()

        if cmd == "playplay":
            ret_code = self.main.mpc.play()

        if cmd == "playpos":
            ret_code = PLAY_JUMP
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "playpos requires 1 int arg"
            else:
                self.main.mpc.playpos(int_args[1])

        if cmd == "playprev":
            ret_code = PLAY_PREV
            self.main.mpc.previous()

        if cmd == "playstatus":
            # show current playlist item
            info = self.main.mpc.get_play_status()
            if len(info) == 0:
                ret_stat = -1
            else:
                ret_list = [info]
            ret_code = PLAY_INFO

        if cmd == "playstop" or cmd == "stop":
            ret_code = PLAY_STOPPED
            self.main.mpc.stop()

        if cmd == "playtoggle" or cmd == "playpause":
            ret_code = self.main.mpc.toggle()

        if cmd == "poweroff":
            ret_code = CON_POWEROFF
            ret_stat = STATUSEXIT
            self.main.keep_run = 0
            self.main.ret_code = 10  # tell init script to invoke poweroff

        if cmd == "quit":
            ret_code = CON_QUIT
            ret_stat = STATUSEXIT
            self.main.keep_run = 0

        if cmd == "setequal":
            ret_code = EQUAL_CHANNEL_CHANGED
            if len(line) != 3 or int_args[1] is None or int_args[2] is None:
                ret_stat = ERRORARGS
                ret_msg = "setequal requires 2 int args"
            else:
                self.main.alsa.set_equal_channel(int_args[1], int_args[2])

        if cmd == "setequalstatus":
            ret_code = EQUAL_STATUS
            if len(line) != 2:
                ret_stat = ERRORARGS
                ret_msg = "setequalstatus requires 1 arg"
            else:
                self.main.alsa.set_equal_status(line[1])
                if self.main.alsa.has_equalizer():
                    chans = self.main.alsa.equal_channels
                    vals = ["%d" % i for i in self.main.alsa.get_equal_vals()]
                    ret_list = [vals, chans]

        if cmd == "setpos":
            ret_code = PLAY_POS
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "setpos needs 1 int arg"
            else:
                self.main.mpc.seek_current(int_args[1])

        if cmd == "setvolume":
            ret_code = VOL_MASTER_CHANGED
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "setvolume needs 1 int arg"
            else:
                self.main.mpc.set_volume(int_args[1])

        if cmd == "setvolumeamp":
            ret_code = VOL_AMP_CHANGED
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "setvolumeamp needs 1 int arg"
            else:
                self.main.i2c.write_volume(int_args[1])

        if cmd == "setvolumemixer":
            ret_code = VOL_MIXER_CHANGED
            if len(line) != 2 or int_args[1] is None:
                ret_stat = ERRORARGS
                ret_msg = "setvolumemixer needs 1 int arg"
            else:
                self.main.alsa.set_master_volume(int_args[1])

        if cmd == "togglerandom":
            ret_code = TOGGLE_RANDOM
            self.main.mpc.toggle_random()

        if cmd == "togglerepeat":
            ret_code = TOGGLE_REPEAT
            self.main.mpc.toggle_repeat()

        if cmd == "voldec":
            ret_code = VOL_MIXER_CHANGED
            self.main.mpc.change_volume(-2)

        if cmd == "volinc":
            ret_code = VOL_MIXER_CHANGED
            self.main.mpc.change_volume(2)

        if cmd == "volstatus":
            master = self.main.mpc.volume()
            mixer = self.main.alsa.get_master_volume()
            amp = self.main.i2c.read_volume()
            ret_code = VOL_STATUS
            ret_list = [["%d" % i for i in [master, mixer, amp]]]

        # # # END EVAL CMD # # #

        if ret_code == -1:
            ret_stat = ERRORUNKNOWN
            ret_msg = "unknown command"

        self.main.log.write(log.MESSAGE, ">>> %s" % ret_msg)

        if src != 'button' and ret_stat != STATUSEXIT:
            if ret_stat == STATUSOK:
                self.main.led.flash_led(gpio.WHITE, 1.0)
            else:
                self.main.led.flash_led(gpio.RED, 1.0)

        return [ret_stat, ret_code, ret_msg, ret_list]
