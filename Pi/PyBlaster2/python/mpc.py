"""mpc.py -- Manage connection to MusicPlayerDaemon

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

from mpd import MPDClient, ConnectionError, CommandError
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
        """Try to reconnect to mpd if connection was lost.

        Try 5 times, raise error if no success.
        """
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
        self.toggle_repeat()
        time.sleep(0.5)
        self.toggle_repeat()
        time.sleep(0.5)

    def get_status(self):
        """Get status dict from mpd.
        If connection error occurred, try to reconnect max 5 times.

        :return: {'audio': '44100:24:2',
                 'bitrate': '320',
                 'consume': '0',
                 'elapsed': '10.203',
                 'mixrampdb': '0.000000',
                 'mixrampdelay': 'nan',
                 'nextsong': '55',
                 'nextsongid': '55',
                 'playlist': '2',
                 'playlistlength': '123',
                 'random': '1',
                 'repeat': '1',
                 'single': '0',
                 'song': '58',
                 'songid': '58',
                 'state': 'pause',
                 'time': '10:191',
                 'volume': '40',
                 'xfade': '0'}
        """
        for i in range(5):
            try:
                return self.client.status()
            except (ConnectionError, CommandError):
                self.reconnect()
                pass

        raise Exception("Failed to get status from MPD!")

    def ensure_connected(self):
        """Fetch status which retries 5 times to reconnect if not connected.
        """
        self.get_status()

    def get_status_int(self, key, dflt=0):
        """Fetch value from mpd status dict as int,
        fallback to dflt if no such key.

        Won't catch failed conversions.
        """
        stat = self.get_status()
        if key in stat:
            return int(stat[key])
        return dflt

    def get_status_string(self, key, dflt=''):
        """Fetch value from mpd status dict as string,
        fallback to dflt if no such key.
        """
        stat = self.get_status()
        if key in stat:
            return stat[key]
        return dflt

    def get_currentsong(self):
        """Fetch current song dict from mpd.
        Force reconnect if failed.

        :return: {'album': 'Litany',
                 'albumartist': 'Vader',
                 'artist': 'Vader',
                 'date': '2000',
                 'file': 'local/Extreme_Metal/Vader - Litany - 01 - Wings.mp3',
                 'genre': 'Death Metal',
                 'id': '58',
                 'last-modified': '2014-12-10T20:00:58Z',
                 'pos': '58',
                 'time': '191',
                 'title': 'Wings',
                 'track': '1'}
        """
        self.ensure_connected()
        return self.client.currentsong()

    def update_database(self):
        """Trigger mpd update command (!= rescan).
        Idler will get notified when scan is done.
        """
        self.ensure_connected()
        self.client.update()

    def volume(self):
        """Current volume as int in [0,100]"""
        return self.get_status_int('volume')

    def change_volume(self, amount):
        """Add amount to current volume int [-100, +100]"""
        self.set_volume(self.volume() + amount)

    def set_volume(self, setvol):
        """Set current volume as int in [0,100]"""
        self.ensure_connected()
        vol = setvol
        if vol < 0:
            vol = 0
        if vol > 100:
            vol = 100
        self.client.setvol(vol)
        return self.volume()

    def get_play_status(self):
        """Get status of current song.
        Invoked by "playstatus" command via Cmd.eval()

        :return: [rand_stat, repeat_stat, state, volume, time, length, album,
                  artist, title, file, year, genre, track-no, position]
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
                    'track',
                    'pos']

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
                filename = cur['file'] if key in cur else 'NOT PLAYING'
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
        self.ensure_connected()
        self.client.pause()
        return self.play_status()

    def play(self):
        self.ensure_connected()
        self.client.play()
        return self.play_status()

    def playpos(self, pos):
        pl_len = self.get_status_int('playlistlength')
        if pos < pl_len:
            self.client.play(pos)

    def stop(self):
        self.ensure_connected()
        self.client.stop()
        return self.play_status()

    def next(self):
        self.ensure_connected()
        self.client.next()

    def previous(self):
        self.ensure_connected()
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

    def playlistinfo_current(self, amount):
        """Get list of playlist items around current song
        :param amount: number of items to fetch from playlist
        :return: amount items from playlistinfo()
        """
        if amount == 0:
            return self.playlistinfo(0, -1)

        song_pos = self.get_status_int('song')
        start = max(0, song_pos - int(amount/2))
        end = start + amount

        return self.playlistinfo(start, end)

    def playlistinfo(self, start, end):
        """Get playlist items in interval [start, end)

        :param start: start index in playlist (start = 0)
        :param end: end index in playlist (excluded)
        :return: [[pos, title, artist, album, length]]
        """

        pl_len = self.get_status_int('playlistlength')

        if end == -1:
            end = pl_len

        if end < start:
            return []

        if start >= pl_len:
            return []

        result = []
        items = self.client.playlistinfo("%d:%d" % (start, end))
        for item in items:
            length = time.strftime("%M:%S", time.gmtime(int(item['time'])))
            res = [item['pos'], '', '', '', length, item['id']]
            if 'title' in item:
                res[1] = item['title']
            else:
                no_ext = os.path.splitext(item['file'])[0]
                res[1] = os.path.basename(no_ext).replace('_', ' ')
            if 'artist' in item:
                res[2] = item['artist']
            if 'album' in 'item':
                res[3] = item['album']

            result.append(res)

        return result

    def playlist_clear(self):
        """Clear out whole playlist
        """
        self.ensure_connected()
        self.client.clear()
        self.resend_playlist()

    def playlist_shuffle(self):
        """shuffle playlist
        """
        # TODO 'from:to'
        self.ensure_connected()
        self.client.shuffle()
        self.resend_playlist()

    def playlist_delete(self, payload):
        """Delete items from playlist

        :param payload: unsorted list of string ids
        """
        self.ensure_connected()
        if not len(payload):
            return

        for i in sorted([int(x) for x in payload], reverse=True):
            try:
                self.client.deleteid(i)
            except CommandError:
                pass

        self.resend_playlist()

    def playlist_move_selection(self, payload, mode=1):
        """

        :param payload:
        :return:
        """
        self.ensure_connected()
        if not len(payload):
            return

        move_to = -1  # == after current
        if mode == 2:
            move_to = self.get_status_int('playlistlength') - 1

        for i in [int(x) for x in payload][::-1]:
            try:
                self.client.moveid(i, move_to)
            except CommandError as e:
                print("MOVE ERROR %d -> %d: %s" % (i, move_to, e))
                pass

        self.resend_playlist()

    def playlist_move(self, songid, toposition):
        """
        """
        self.ensure_connected()
        try:
            self.client.moveid(songid, toposition)
        except CommandError as e:
            print("MOVE ERROR %d -> %d: %s" % (songid, toposition, e))
            pass
        self.resend_playlist()

    def resend_playlist(self):
        """Let application send updated playlist data to client.

        Invokes bluetooth send.
        """
        res = self.main.cmd.eval('playlistinfocurrent 0', 'idler')
        self.main.bt.send_client([-1] + res)

    def browse(self, folder):
        """

        :param folder:
        :return:
        """
        if folder is None:
            return None

        self.ensure_connected()

        result = []

        try:
            lsdir = self.client.lsinfo(folder)
        except CommandError:
            return None

        for item in lsdir:
            if 'directory' in item:
                title = os.path.basename(item['directory'])
                result.append(['1', title, '', '', '', item['directory']])
            else:
                length = time.strftime("%M:%S", time.gmtime(int(item['time'])))
                res = ['2', '', '', '', length, item['file']]
                if 'title' in item:
                    res[1] = item['title']
                else:
                    no_ext = os.path.splitext(item['file'])[0]
                    res[1] = os.path.basename(no_ext).replace('_', ' ')
                if 'artist' in item:
                    res[2] = item['artist']
                # TODO: album seems to be missing
                if 'album' in 'item':
                    res[3] = item['album']
                result.append(res)

        return result

    def playlist_add(self, payload, mode=1):
        """

        :param payload:
        :param mode:
        :return:
        """
        if not len(payload):
            return

        self.ensure_connected()

        self.main.led.set_led_yellow(1)

        if mode == 1 or 'position' not in self.get_currentsong():
            # Insert at end
            for item in payload:
                try:
                    self.client.add(item)
                except CommandError:
                    print("ADD URI ERROR: "+item)
                    pass
        else:
            # Insert after current -- reversed order
            for item in reversed(payload):
                try:
                    self.client.addid(item, -1)
                except CommandError:
                    print("ADD URI ERROR: "+item)
                    pass

        self.main.led.set_led_yellow(0)

    def search_file(self, arg):
        """

        :param arg:
        :return:
        """
        if arg is None or len(arg) < 3:
            return []

        self.ensure_connected()

        result = []

        self.main.log.write(log.DEBUG1, "[MPD] Search: %s" % arg)

        try:
            search = self.client.search('file', arg)
        except CommandError as e:
            self.main.log.write(log.DEBUG1, "[MPD] ERROR SEARCH: %s" % e)
            return None

        self.main.log.write(log.DEBUG1, "[MPD] Search done - %d results" %
                            len(search))

        for item in search:

            length = time.strftime("%M:%S", time.gmtime(int(item['time'])))
            res = ['', '', '', length, item['file']]
            if 'title' in item:
                res[0] = item['title']
            else:
                no_ext = os.path.splitext(item['file'])[0]
                res[0] = os.path.basename(no_ext).replace('_', ' ')
            if 'artist' in item:
                res[1] = item['artist']
            # TODO: album seems to be missing
            if 'album' in 'item':
                res[2] = item['album']
            result.append(res)

        return result

    def exit_client(self):
        """Disconnect from mpc

        Call after join(), short before end of program
        """
        try:
            self.client.disconnect()
        except ConnectionError:
            pass
