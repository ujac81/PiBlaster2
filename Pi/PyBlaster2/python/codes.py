"""codes.py -- code list for communication to android APP



@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

PASS_OK = 1         # correct password sent
PASS_ERROR = 2      # wrong password

CON_DISCONNECT = 10
CON_POWEROFF = 11
CON_QUIT = 12

PLAY_INFO = 304     # answer on playstatus

PLAY_STOPPED = 305
PLAY_PAUSED = 306
PLAY_PLAYING = 307
PLAY_NEXT = 308
PLAY_PREV = 309
PLAY_POS = 310

TOGGLE_RANDOM = 311
TOGGLE_REPEAT = 312

VOL_MIXER_CHANGED = 401

KEEP_ALIVE = 1000   # answer on keepalive
