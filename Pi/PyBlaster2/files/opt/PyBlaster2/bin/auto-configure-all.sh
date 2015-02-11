




sudo aptitude install vim usbmount  python3-pip libbluetooth-dev cmake gdebi-core mpd mpc libasound2-plugin-equal libasound2-plugins i2c-tools ipython3



# patch /etc/inputrc


# patch /etc/inittab
# 1:2345:respawn:/sbin/getty --autologin pi --noclear 38400 tty1


#/etc/modprobe.d/raspi-blacklist.conf
#blacklist spi-bcm2708
#blacklist i2c-bcm2708
#blacklist snd-soc-pcm512x
#blacklist snd-soc-wm8804

# /etc/modules
i2c-dev
i2c-bcm2708
lirc_dev
lirc_rpi gpio_in_pin=26
snd_soc_bcm2708
bcm2708_dmaengine
snd_soc_pcm512x
snd_soc_hifiberry_dacplus


# /etc/asound.conf
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




# /etc/mpd.conf
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


sudo pip-3.2 install python-mpd2
sudo pip-3.2 install pybluez





