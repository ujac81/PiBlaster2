"""alsamixer.py -- Control alsa mixer and equalizer

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

import alsaaudio
import math
import re
from subprocess import Popen, PIPE

import log


class AlsaMixer:
    """Control alsa mixer master channel and equalizer plugin if found.
    """

    def __init__(self, main):
        """Get names of equalizer channels if such.
        """

        self.main = main
        self.mixers = alsaaudio.mixers()
        self.equal_channels = []  # names of equalizer channels if found
        self.mixer = self.main.settings.mixer_channel

        # alsaaudio.Mixer().setvolume() is somehow strange.
        # At least for my device.
        # Assume a*Exp[b x] -> [0,1]; x in [0,1] behaviour.

        # Fit parameter gathered from Mathematica (or Wolframalpha) using:
        # NonlinearModelFit[{{0,0},{0.1,0.02},{0.20,0.04},{0.30,0.06},
        #                    {0.40, 0.08},{0.50,0.13},{0.60,0.19},
        #                    {0.70,0.29},{0.80,0.44},{0.90,0.67},{0.99,0.96}},
        #                    a*Exp[b*x], {a,b}, x]
        # Values retrieved by comparing python alsaaudio's values with
        # displayed values from alsamixer on command line.
        self.fit_a = 0.0161362
        self.fit_b = 4.13073

    def init_alsa(self):
        """

        :return:
        """
        if not self.mixers:
            raise Exception("AlsaMixer: No mixers found!")

        if self.mixer not in self.mixers:
            self.main.log.write(log.MESSAGE,
                                "[ALSA] desired mixer channel not found! "
                                "Falling back to %s." % self.mixers[0])
            self.mixer = self.mixers[0]
        self.init_equal_channels()

    def get_master_volume(self):
        """Get volume of alsa master channel for sound card #0
        :return: value between 0 and 100
        """

        # getvolume / setvolume is totally strange for alsaaudio.Mixer().
        # (at least for my device)
        # This is the best fit for a*e^(bx) behaviour.

        vol = alsaaudio.Mixer(self.mixer).getvolume()[0]
        if vol == 100:
            return 100
        if vol == 0:
            return 0

        vol2 = int(100 * self.fit_a*math.exp(self.fit_b*vol/100.))
        if vol2 < 0:
            return 0
        if vol2 > 100:
            return 100

        return vol2

    def set_master_volume(self, val):
        """Set volume of alsa master channel for sound card #0
        :param val: volume value in [0,100]
        """

        # getvolume / setvolume is totally strange for alsaaudio.Mixer().
        # (at least for my device)
        # This is the best fit for a*e^(bx) behaviour.
        # For set volume inverse function 1/b*log(x/a) is used.

        if val == 0:
            vol = 0
        elif val == 100:
            vol = 100
        else:
            vol2 = int(100 * (1/self.fit_b*math.log(val/100./self.fit_a)))
            if vol2 < 0:
                vol = 0
            elif vol2 > 100:
                vol = 100
            else:
                vol = vol2

        self.main.log.write(log.MESSAGE, "[ALSA] setting mixer volume to "
                                         "%d (=%d)..." % (val, vol))
        alsaaudio.Mixer(self.mixer).setvolume(vol)

    def has_equalizer(self):
        """True if alsa device named 'equal' found.

        Requires installed plugequal alsa plugin.

        :return: True if equal mixer found.
        """
        return len(self.equal_channels) > 0

    def init_equal_channels(self):
        """Check if amixer -D equal returns list of equalizer channels.

        Will only work if alsa plugin equal loaded as 'equal'.
        """

        channels = Popen(["sudo", "amixer", "-D", "equal", "scontrols"],
                         stdout=PIPE, stderr=PIPE).\
            communicate()[0].decode('utf-8').split('\n')

        self.equal_channels = []
        for chan in channels:
            m = re.search('\d+ k?Hz', chan)
            if m is not None:
                self.equal_channels.append(m.group(0))

        self.main.log.write(log.MESSAGE, "[ALSA]: found equal channels: %s" %
                            ' '.join(self.equal_channels))

    def get_equal_vals(self):
        """Get list of int values for equalizer channels.
        :return: [equal_channel_i_val([0..100]), ...]
        """
        if not len(self.equal_channels):
            return []

        channels = Popen(["sudo", "amixer", "-D", "equal", "contents"],
                         stdout=PIPE, stderr=PIPE).\
            communicate()[0].decode('utf-8').split('\n')

        res = []
        for chan in channels:
            m = re.search('values=(\d+),(\d+)', chan)
            if m is not None:
                res.append((int(m.group(1)) + int(m.group(2))) / 2)

        return res

    def set_equal_channel(self, chan, val):
        """Set equalizer channel by channel id.

        Invokes `amixer -D equal cset numid=(chan+1) (val)`.

        :param chan: channel as integer value [0..N_channels-1].
        :param val: value between 0 and 100
        """
        if chan >= len(self.equal_channels):
            return

        if val < 0:
            val = 0
        if val > 100:
            val = 100

        Popen(["sudo", "amixer", "-D", "equal", "cset", "numid=%d" % (chan+1),
               "%s" % val], stdout=PIPE, stderr=PIPE).communicate()

        self.main.log.write(log.MESSAGE,
                            "[ALSA] set equal channel %d to %d." % (chan, val))

    def set_equal_channels(self, valstring):
        """Set all equalizer channels by space separated string.

        :param valstring: N_channels space separated values between 0 and 100.
        """
        vals = valstring.split()
        if len(vals) != len(self.equal_channels):
            return

        int_vals = []
        for val in vals:
            try:
                int_arg = int(val)
                if int_arg < 0:
                    int_arg = 0
                if int_arg > 100:
                    int_arg = 100
                int_vals.append(int_arg)
            except TypeError:
                int_vals.append(66)
            except ValueError:
                int_vals.append(66)

        cmd = ""
        for i in range(len(int_vals)):
            cmd += "sudo amixer -D equal cset numid=%d %s;" % \
                   (i+1, int_vals[i])

        if not len(cmd):
            return

        Popen(cmd, stdout=PIPE, stderr=PIPE, shell=True).communicate()

        self.main.log.write(log.MESSAGE,
                            "[ALSA] set equal channels to %s" %
                            ' '.join('%d' % x for x in int_vals))

    def set_equal_status(self, status):
        """

        :param status:
        """

        self.main.log.write(log.MESSAGE, "[ALSA] Setting equalizer to '%s'"
                            % status)

        vals = ' '.join(['66']*len(self.equal_channels))

        if status == "bass":
            vals = "77 76 75 72 66 66 66 66 66 66"
        if status == "morebass":
            vals = "85 85 81 74 66 66 66 66 66 66"
        if status == "maxbass":
            vals = "100 100 93 79 66 66 66 66 66 66"
        if status == "lessbass":
            vals = "40 45 50 60 66 66 66 66 66 66"
        if status == "lesserbass":
            vals = "30 35 40 60 66 66 66 66 66 66"
        if status == "moremid":
            vals = "60 65 74 78 82 82 78 74 64 60"
        if status == "lessmid":
            vals = "82 78 74 65 60 60 65 74 78 82"
        if status == "moretrebble":
            vals = "66 66 66 66 66 66 72 75 76 77"

        self.set_equal_channels(vals)

