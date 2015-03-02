"""mpc.py -- Manage connection to MusicPlayerDaemon

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

from mpd import MPDClient, ConnectionError
import os
import queue
import sys
import time
import threading

import codes
import log


class MPDIdler(threading.Thread):
    """Idler loop to receive events sent by MusicPlayer Daemon.

    E.g.: update done, song changed, ....
    """

    def __init__(self, main, queue, queue_lock):
        threading.Thread.__init__(self)
        self.main = main
        self.queue = queue
        self.queue_lock = queue_lock
        self.client = MPDClient()
        self.client.timeout = 10

    def connect(self):
        """Try to establish connection to MPD, retry until main wants to exit.
        """

        try:
            self.client.disconnect()
        except ConnectionError:
            pass

        while self.main.keep_run:
            connected = False
            try:
                self.client.connect('localhost', 6600)
                connected = True
            except ConnectionError:
                self.main.log.write(log.ERROR, "[MPDIdler]: Failed to "
                                               "connect! -- retrying...")
                time.sleep(0.1)
                pass
            if connected:
                self.main.log.write(log.MESSAGE, "[MPDIdler]: connected.")
                return

    def run(self):
        """Loop and read MPD events, until main wants to exit.

        Read of events is blocking, so a fake event has to be sent, after main
        wanted to exit.
        """
        # try:

        self.connect()

        while self.main.keep_run:

            try:
                res = self.client.idle()
                if self.main.keep_run:
                    self.queue_lock.acquire()
                    self.queue.put(res)
                    self.queue_lock.release()
            except ConnectionError:
                self.connect()
                pass

        self.client.disconnect()
        self.main.log.write(log.MESSAGE, "[THREAD] MPD Idler leaving...")

        # except ConnectionError:
        #     # Failed on disconnect.
        #     pass
        # # catch any exceptions here and pass them to the main thread.
        # except Exception:
        #     self.main.ex_queue.put(sys.exc_info())
        #     pass


class MPC:
    """Send commands to MusicPlayer Daemon and manage idler loop.
    """

    def __init__(self, main):
        self.main = main
        self.client = None
        self.queue = queue.Queue()
        self.queue_lock = threading.Lock()
        self.idler = MPDIdler(self.main, self.queue, self.queue_lock)
        self.client = MPDClient()
        self.client.timeout = 10

    def connect(self):
        """Connect to MPD, retry 5 times, than raise.
        """

        self.idler.start()
        self.reconnect()

    def reconnect(self):
        connected = False

        try:
            self.client.disconnect()
        except ConnectionError:
            pass

        for i in range(5):
            try:
                self.client.connect('localhost', 6600)
                connected = True
            except ConnectionError:
                time.sleep(0.1)
                pass
            if connected:
                self.main.log.write(log.MESSAGE, "[MPC] connected.")
                return

        raise Exception("Failed to connect to MPD!")

    def process_idler_events(self):
        """Check if idler thread got any events and process them."""
        if self.queue.empty() or self.main.keep_run is False:
            return

        self.queue_lock.acquire()
        try:
            events = self.queue.get_nowait()
        except queue.Empty:
            self.queue_lock.release()
            return
        self.queue_lock.release()

        self.main.log.write(log.MESSAGE, "[MPD event]: %s" % events)

        for event in events:
            if event == 'player' or event == 'options' or event == 'mixer':
                res = self.main.cmd.eval('playstatus', 'idler')
                self.main.bt.send_client([-1] + res)
            if event == 'mixer':
                res = self.main.cmd.eval('volstatus', 'idler')
                self.main.bt.send_client([-1] + res)

    def join(self):
        """Join all button threads after keep_run in root is False.
        """
        # This is a dirty hack.
        # join() is called after main loop left in PyBlaster.
        # The loop in MPDIdler should exit now, but would hang in idle().
        # So we trigger some mpd command to wake up the idler and MPDIdler
        # thread can exit.
        # self.client.sendmessage('pyblaster', 'quit')
        print("join 1")
        self.toggle_repeat()
        time.sleep(0.5)
        print("join 2")
        self.toggle_repeat()
        time.sleep(0.5)
        print("join done")

    def get_status(self):
        for i in range(5):
            try:
                return self.client.status()
            except ConnectionError:
                self.reconnect()
                pass

        raise Exception("Failed to get status from MPD!")

    def get_status_int(self, key, dflt=0):
        stat = self.get_status()
        if key in stat:
            return int(stat[key])
        return dflt

    def get_status_string(self, key, dflt=''):
        stat = self.get_status()
        if key in stat:
            return stat[key]
        return dflt

    def get_currentsong(self):
        for i in range(5):
            try:
                return self.client.currentsong()
            except ConnectionError:
                self.reconnect()
                pass

        raise Exception("Failed to get current song from MPD!")

    def update_database(self):
        """Trigger mpd update command (!= rescan).
        Idler will get notified when scan is done.
        """
        self.client.update()

    def volume(self):
        return self.get_status_int('volume')

    def change_volume(self, amount):
        self.set_volume(self.volume() + amount)

    def set_volume(self, setvol):
        vol = setvol
        if vol < 0:
            vol = 0
        if vol > 100:
            vol = 100
        self.client.setvol(vol)
        return self.volume()

    def get_play_status(self):
        """

        :return:
        """

        result = []
        stat_keys = ['random',
                     'repeat',
                     'state',
                     'volume',
                     'time']
        cur_keys = ['time',
                    'album',
                    'albumartist',
                    'title',
                    'file',
                    'date',
                    'genre',
                    'track']

        status = self.get_status()
        cur = self.get_currentsong()

        for key in stat_keys:
            res = status[key] if key in status else ''
            if key == 'time' and res == '':
                res = '0'
            if key == 'time':
                res = res.split(':')[0]
            result.append(res)

        for key in cur_keys:
            res = cur[key] if key in cur else ''
            if key == 'title' and res == '':
                filename = cur['file']
                ext = os.path.splitext(filename)[1]
                res = os.path.split(filename)[1].replace(ext, '').\
                    replace('_', ' ')
            result.append(res)

        return result

    def play_status(self):
        """0 if stopped, 1 if paused, 2 if playing
        """
        status = self.get_status_string('state')
        if status == 'stop':
            return codes.PLAY_STOPPED
        if status == 'pause':
            return codes.PLAY_PAUSED
        return codes.PLAY_PLAYING

    def toggle(self):
        """Toggle play/pause
        :return: new play status from self.play_status()
        """
        status = self.play_status()
        self.pause() if status == codes.PLAY_PLAYING else self.play()
        return self.play_status()

    def pause(self):
        self.client.pause()

    def play(self):
        self.client.play()

    def stop(self):
        self.client.stop()

    def next(self):
        self.client.next()

    def previous(self):
        self.client.previous()

    def seek_current(self, time):
        song_pos = self.get_status_int('song')
        self.client.seek(song_pos, time)

    def toggle_random(self):
        rand = self.get_status_int('random')
        self.client.random(1 if rand == 0 else 0)

    def toggle_repeat(self):
        rep = self.get_status_int('repeat')
        self.client.repeat(1 if rep == 0 else 0)

    def exit_client(self):
        """Disconnect from mpc

        Call after join(), short before end of program
        """
        try:
            self.client.disconnect()
        except ConnectionError:
            pass
