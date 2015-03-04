"""i2c.py -- control amp via I2C

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

import smbus

import log


class I2C:
    """

    """

    def __init__(self, main):
        """
        """

        self.main = main
        self.bus = None

    def open_bus(self):
        """

        :return:
        """

        if self.main.settings.amp_i2cbus == -1:
            return

        try:
            self.bus = smbus.SMBus(self.main.settings.amp_i2cbus)
            vol = self.bus.read_byte(self.main.settings.amp_i2caddress)
            self.main.log.write(log.MESSAGE,
                                "[I2C]: got amp volume via i2c: %d" % vol)
        except IOError:
            self.main.log.write(log.ERROR, "[I2C]: failed to open device.")
            self.bus = None
            pass

    def read_volume(self):
        """

        :return:
        """
        if self.bus is None:
            return 0

        vol = self.bus.read_byte(self.main.settings.amp_i2caddress)
        return int(100*vol/63)

    def write_volume(self, vol):
        """

        :return:
        """
        if self.bus is None:
            return

        vol2 = int(vol/100*63)
        if vol2 > 63:
            vol2 = 63
        if vol < 0:
            vol2 = 0

        self.bus.write_byte(self.main.settings.amp_i2caddress, vol2)
