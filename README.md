#PiBlaster2

Docs and source code for the PiBlaster project....

**To be completed...**

# Development Environment

## Software

### Android SDK
Download latest sdk tools from [android SDK download site](http://developer.android.com/sdk/).
Untar it and put it to a desired location. Run the update manager

    # from android sdk folder
    $ tools/android update sdk

and install the updates. Make sure to select all required platforms e.g.
Android 4.4.2 if required.

**Be warned:** the full android sdk + stuff will require >10gigs of disk space!

### Android NDK
Download latest native development kit from [android NDK download site](http://developer.android.com/tools/sdk/ndk).
As of 2015/02/07 there is a bin which is a self extracting archive. Make it
executable and run it.

    $ chmod a+x android-ndk-r10d-linux-x86_64.bin
    $ ./android-ndk-r10d-linux-x86_64.bin

You might move the kit wherever you want.

### QtCreator 5.3 on unbuntu linux 14.10
Download Qt >= 5.31 online installer and run it

    $ chmod 755 qt-opensource-linux-x64-1.6.0-4-online.run
    $ sudo qt-opensource-linux-x64-1.6.0-4-online.run

and install it to any location (/opt/Qt) is okay.
Default selection of packages is ok, just make sure x86_64, armv7 are
selected for Qt and QtCreator is selected for tools.

To configure android kit successfully, install a java sdk and the ant tool.

    $ sudo aptitude install openjdk-7-jdk ant lib32stdc++6 lib32z1

## Compile Application
See [qt docs](http://doc.qt.io/qtcreator/creator-developing-android.html)
on how connecting android devices.
If configured correctly, just hit deploy button and wait for the application
 to start on your android device.

# Set up Raspberry Pi

## Installation of latest Raspbian
See [installing images on linux](http://www.raspberrypi.org/documentation/installation/installing-images/linux.md)

### Download
[Download](http://www.raspberrypi.org/downloads/)
zip image for Raspbian (debian wheezy) and unzip it.

### Write SD
Insert empty SD card and make sure its not mounted Check the device name of
the inserted SD card

    $ dmesg | tail

it should print some information about the last connected device or so.
You need the device name like [sdb] or [sdc]. **Don't make any mistake here** or you
might mess up one of your working devices!

Copy image to SD card:

    $ sudo dd bs=4M if=2014-06-20-wheezy-raspbian.img of=/dev/sdX

put the device later instead of the last X

### Boot Pi and upgrade
Place SD card into PI and connect LAN, monitor and keyboard.
In the software configuration select

* Expand Filesystem
* Advanced options -> ssh -> enable

and reboot. If connected via LAN you can now use ssh to connect to your PI.
Default password for user pi is *raspberry*.

To set locale do

    $ sudo dpkg-reconfigure locales

You can select en_US.UTF-8. Relogin to apply locales for your terminal.

To upgrade run

    $ sudo aptitude update
    $ sudo aptitude upgrade
    $ sudo rpi-update

### Dist-Upgrade to debian jessie

TODO.

## Configure Raspberry Pi

### Disable display manager in jessie
Comment out the default display manager in */etc/X11/default-display-manager*
and add

    /bin/true

to that file.

### Install required python packages
PyBlaster won't start if some python packages are missing

    $ sudo aptitude install python3-pip python3-dev libbluetooth-dev libasound2-dev libffi-dev libi2c-dev
    $ sudo pip-3.2 install python-mpd2
    $ sudo pip-3.2 install pybluez
    $ sudo pip-3.2 install pyalsaaudio
    $ sudo pip-3.2 install cffi
    $ sudo pip-3.2 install smbus-cffi

Documentation of python-mpd2 can be found [here](http://pythonhosted.org/python-mpd2/topics/getting-started.html)

### Download and install PiBlaster2 software
You can download and create the piblaster package right on your PI, all you
need is cmake

    $ sudo aptitude install cmake gdebi-core

You can skip this if you install a pre-packed package and install the
dependencies by hand.

Now clone the git repo and create the package

    # -- $ omitted, so you can copy and paste the whole block
    cd /tmp
    git clone https://github.com/ujac81/PiBlaster2.git
    cd PiBlaster2/Pi/PyBlaster2/
    mkdir build
    cd build
    cmake ..
    cpack

To install the package with dependencies run

    $ sudo gdebi pyblaster2-*-armhf.deb

### Install MPD -- the easy way
Configure music player daemon which is used as sound back-end for PyBlaster2.

Install it like

    $ sudo aptitude install mpd mpc

mpc is a command line client for mpd.

These are the settings you have to set in */etc/mpd.conf*

    music_directory         "/var/lib/mpd/music"
    playlist_directory      "/var/lib/mpd/playlists"
    db_file                 "/var/lib/mpd/tag_cache"
    log_file                "/var/log/mpd/mpd.log"
    pid_file                "/var/run/mpd/pid"
    state_file              "/var/lib/mpd/state"
    sticker_file            "/var/lib/mpd/sticker.sql"

    # This is mean on other devices, but OK for raspberry PI as no
    # other important services are run here.
    user                    "root"
    bind_to_address         "localhost"
    auto_update             "yes"
    follow_outside_symlinks "yes"
    follow_inside_symlinks  "yes"

    input {
            plugin "curl"
    }

    # NOTE: this is the setting for the alsa equalizer described below.
    # If not using plugequal, do not touch this section!
    audio_output {
        type            "alsa"
        name            "My ALSA EQ"
        device          "plug:plugequal"
        format          "44100:16:2"
        auto_resample   "no"
        mixer_device    "default"
        mixer_control   "PCM"
        mixer_index     "0"
    }
    # Same as above -- do not touch if using "normal" mixer
    mixer_type              "software"

    filesystem_charset      "UTF-8"
    id3v1_encoding          "UTF-8"

    # restore_paused "yes"

Create symbolic links to your library in */var/lib/mpd/music* like

    # if having a directory local on your SD for local music:
    $ sudo ln -s /local /var/lib/mpd/music

    # For usb devices autmatically mounted by usbmount
    $ sudo ln -s /media/usb0 /var/lib/mpd/music/usb0
    $ sudo ln -s /media/usb1 /var/lib/mpd/music/usb1
    $ sudo ln -s /media/usb2 /var/lib/mpd/music/usb2
    $ sudo ln -s /media/usb3 /var/lib/mpd/music/usb3

Update mpc library by

    $ mpc update

### Hifiberry DAC/AMP/...
If using an extra sound device like Hifiberry DAC or AMP, just configure it.

Unblacklist i2c from */etc/modprobe.d/raspi-blacklist.conf* (just comment
out both lines)
Follow instructions on [Hifiberry site](http://www.hifiberry.com/guides/hifiberry-software-configuration/) and make sure not to load the onboard
sound module in */etc/modules*. Also make sure to have made the Hifiberry made
default in */etc/asound.conf*.

### Better Sound / Equalizer
If you want to install a software equalizer and enhance the sound quality
by best speex encoding do:

    $ sudo aptitude install libasound2-plugin-equal libasound2-plugins

And add

    defaults.pcm.rate_converter "speexrate_medium"

to */etc/asound.conf*. You can also try "speexrate_best", which will consume
more CPU, but not provide way better results. See [alsa-dox](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture#High_quality_resampling).

For the equalizer add some lines to the */etc/asound.conf*. Together with the
Hifiberry device, mine looks like

    pcm.!default  {
     type hw card 0
    }
    ctl.!default {
     type hw card 0
    }


    ctl.equal {
     type equal;
     #controls "/home/pi/.alsaequal.bin"
    }

    pcm.plugequal {
     type equal;
     slave.pcm "plughw:0,0";
     #controls "/home/pi/.alsaequal.bin"
    }

    pcm.equal {
     type plug;
     slave.pcm plugequal;
    }

    defaults.pcm.dmix.rate 44100 # Force 44.1 KHz
    defaults.pcm.dmix.format S16_LE # Force 16 bits
    defaults.pcm.rate_converter "speexrate_medium"

To test your equalizer, use

    $ alsamixer -D equal
    $ mplayer -ao alsa:device=equal Foo.mp3.

**Note:** for later testing, make sure to run *alsamixer -D equal* as that user,
who is playing the music. If e.g. mpd is run as root, you will have to do
*sudo alsamixer -D equal* to get any effect of the equalizer.

### I2C
To use i2c to control amps or other devices, install

    $ sudo aptitude install i2c-tools

Unblacklist i2c from */etc/modprobe.d/raspi-blacklist.conf* (just comment
out both lines). Add

    i2c-dev
    i2c-bcm2708

to */etc/modules* and reboot.
Wire your I2C device to:
 * 3.3V: Vi2c
 * GPIO2: SDA (Raspberry PI B+ -- check for your device!!!)
 * GPIO3: SCL (Raspberry PI B+ -- check for your device!!!)
 * GROUND: GND
[Example for MAX9744 board using i2c](https://learn.adafruit.com/adafruit-20w-stereo-audio-amplifier-class-d-max9744/digital-control)

To control the amplifier mentioned above, use i2cset from command line:

    $ sudo i2cset -y 1 0x4b 0x0 20

Where *1* is the i2c bus id, *0x4b* is the device id of the amplifier
(found via *i2cdetect -y 1* or from documentation), *0x0* is the internal address
for the volume setting and *20* is the volume value between 0 and 63 for this amp.
Be careful, a setting of 35 or 40 might be very loud.
**Note:** This applies for the MAX9744 class D amplifier board from adafruit.
Your settings might differ.


### Configure IR
Follow instructions on
[this page](http://ozzmaker.com/2013/10/24/how-to-control-the-gpio-on-a-raspberry-pi-with-an-ir-remote/)
to wire and configure the remote control.

For a generic remote, use the lirc_rpi module with an extra option to tell
which pin to use in GPIO mode (not board mode!).
To load the module on boot, add these lines to */etc/modules* file

    lirc_dev
    lirc_rpi gpio_in_pin=26

Tell lirc to use the default drivers.
Settings in */etc/lirc/hardware.conf* should be

LIRCD_ARGS=""
LOAD_MODULES=true
DRIVER="default"
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"
LIRCD_CONF=""
LIRCMD_CONF=""

No teach the remote control. Google for irrecord or find a lircd.conf that
matches your remote. To record use

    $ sudo irrecord -d /dev/lirc0 /etc/lirc/lircd.conf

Store the file to */etc/lirc/lircd.conf*.
For my controller it looks like this:

    # Please make this file available to others
    # by sending it to <lirc@bartelmus.de>
    #
    # this config file was automatically generated
    # using lirc-0.9.0-pre1(default) on Tue Oct  8 07:05:38 2013
    #
    # contributed by
    #
    # brand:                       /home/pi/lircd.conf
    # model no. of remote control:
    # devices being controlled by this remote:
    #

    begin remote

      name  /home/pi/lircd.conf
      bits           16
      flags SPACE_ENC|CONST_LENGTH
      eps            30
      aeps          100

      header       9006  4447
      one           594  1648
      zero          594   526
      ptrail        587
      repeat       9006  2210
      pre_data_bits   16
      pre_data       0xFD
      gap          107633
      toggle_bit_mask 0x0

          begin codes
              KEY_1                    0x08F7
              KEY_2                    0x8877
              KEY_3                    0x48B7
              KEY_4                    0x28D7
              KEY_5                    0xA857
              KEY_6                    0x6897
              KEY_7                    0x18E7
              KEY_8                    0x9867
              KEY_9                    0x58A7
              KEY_0                    0x30CF
              KEY_DOWN                 0xB04F
              KEY_LEFT                 0x10EF
              KEY_UP                   0xA05F
              KEY_RIGHT                0x50AF
              KEY_ENTER                0x906F
              KEY_SETUP                0x20DF
              KEY_PLAY                 0x807F
              KEY_AGAIN                0x708F
              KEY_STOP                 0x609F
              KEY_VOLUMEUP             0x40BF
              KEY_VOLUMEDOWN           0x00FF
          end codes

    end remote

The key naming is free, but there is an unwritten standard for the key
naming. So maybe just use these names.

Now lirc daemon should be started on boot.
To tell your application how to use the lirc commands, you need to configure
the *.lircrc* file of the user running the application.
As PiBlaster is run as root at the moment, place the file to */root/.lircrc*

    begin
      button = KEY_PAUSE
      prog = pyblaster
      config = playpause
    end

    begin
      button = KEY_UP
      prog = pyblaster
      config = playprev
    end

    begin
      button = KEY_DOWN
      prog = pyblaster
      config = playnext
    end

    begin
      button = KEY_VOLUMEUP
      prog = pyblaster
      config = volinc
      repeat = 2
    end

    begin
      button = KEY_VOLUMEDOWN
      prog = pyblaster
      config = voldec
      repeat = 2
    end

The pyblaster software will check lircrc for commands for the program
pyblaster and lirc will send the commands given after the config keyword to it.
For the volume increase and decrease command we allow repeat (hold key works).

To run other commands via remote controller, you will have to start the irexec
daemon, but its not required for pyblaster to work.

## Configure PiBlaster

### Run mode
Per default PyBlaster will start on boot in terminal mode. This means it won't
daemonize silently and just do its work, but will print to boot console.
In terminal mode it will also prevent blanking of the screen.
This is good for development/debugging, but might not be the right thing for
you. To enable/disable terminal mode, check */etc/default/pyblaster2* file.

## Faster Boot for Raspberry PI

### Set Static Network Address
If using model B, set a static ethernet address in */etc/network/interfaces*
like

    auto lo

    iface lo inet loopback
    iface eth0 inet static
            address 192.168.X.Y
            gateway 192.168.X.Z
            netmask 255.255.255.0
            dns-nameservers 192.168.X.Z

    allow-hotplug wlan0
    iface wlan0 inet manual
            wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf


And set your nameserver in */etc/resolv.conf*

    nameserver 192.168.X.Z

### Overclocking
To overclock your Pi while add this to */boot/config.txt*

    arm_freq=1000
    core_freq=500
    sdram_freq=600
    over_voltage=6
    force_turbo=1

**Note:** Higher values will set a sticky bit inside the Pi and your warranty
will be voided. This will boost your boot time by ~50%, but will lead to a
higher power consumption. Also your Pi might run unstable. You have to play
with the overclock settings to find something that suits your requirements.
I disabled overclocking for my Pi because I want to save power and I found
that my Pi runs unstable with these settings.


# Note for developers
If you have a second screen to connect to the Pi, there is a nice tmux setup
to display some interesting data on that screen, while testing your stuff.
To let the Pi automatically log in and start the pyblaster2 daemon in terminal
mode, change this line inside your */etc/inittab*:

    1:2345:respawn:/sbin/getty --autologin pi --noclear 38400 tty1

A file place in */etc/profile.d* installed by pyblaster2 package will launch
a tmux window if a screen is connected and *PYBLASTER_RUN_TMUX=1* is set in
*/etc/default/pyblaster2*. Note: this setup will prevent the normal daemon
from starting at boot, but this is intended. You don't need 2 pyblaster2
instances at a time ;)

