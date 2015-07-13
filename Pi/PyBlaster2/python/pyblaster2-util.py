#!/usr/bin/env python3
""" pyblaster2-util.py -- test scripts for Piblaster2

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

import argparse
import RPi.GPIO as GPIO
import os


class PyBlasterUtils:
    """

    """
    def __init__(self):
        """

        :return:
        """

        self.defaultfile = "/etc/default/pyblaster2"
        self.args = None
        self.defvars = {}

    def arg_parse(self):
        """

        :return:
        """
        parser = argparse.ArgumentParser()
        parser.add_argument("-s", "--shutdown",
                            help="Flash LEDs for shutdown mode",
                            action="store_true")
        parser.add_argument("-i", "--init",
                            help="Flash LEDs for init mode",
                            action="store_true")
        parser.add_argument("-e", "--error",
                            help="Flash LEDs for error mode",
                            action="store_true")

        self.args = parser.parse_args()
        self.read_default()

        if self.args.shutdown:
            self.flash_shutdown_leds()
        if self.args.init:
            self.flash_init_leds()
        if self.args.error:
            self.flash_error_leds()

    def flash_shutdown_leds(self):
        self.flash_leds(['PYBLASTER_LED_RED', 'PYBLASTER_LED_YELLOW'])

    def flash_init_leds(self):
        self.flash_leds(['PYBLASTER_LED_RED', 'PYBLASTER_LED_YELLOW',
                         'PYBLASTER_LED_GREEN'])

    def flash_error_leds(self):
        self.flash_leds(['PYBLASTER_LED_RED'])

    def flash_leds(self, lst):
        """

        :param lst:
        :return:
        """
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)

        for led in [int(self.defvars[x]) for x in lst]:
            GPIO.setup(led, GPIO.OUT)
            GPIO.output(led, 1)

        # do not cleanup to keep LEDs flashed
        # GPIO.cleanup()

    def read_default(self):
        """Parse default config file /etc/default/pyblaster2
        """

        try:
            f = open(self.defaultfile, "r")
        except IOError:
            print("Failed to open default file %s" % self.defaultfile)
            raise

        for line in f:
            if line.startswith('#') \
                    or len(line) < 3 \
                    or '=' not in line:
                continue

            key = line.split('=', 1)[0].strip()
            val = line.split('=', 1)[1].strip()

            self.defvars[key] = val



if __name__ == '__main__':

    utils = PyBlasterUtils()
    utils.arg_parse()
