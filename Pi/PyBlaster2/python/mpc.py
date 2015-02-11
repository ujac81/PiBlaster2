"""mpc.py -- Manage connection to MusicPlayerDaemon

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

from mpd import MPDClient, ConnectionError
import queue
import sys
import time
import threading


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
        self.client = None

    def connect(self):
        """Try to establish connection to MPD, retry until main wants to exit.
        """

        while self.main.keep_run:
            connected = False
            try:
                self.client = MPDClient()
                self.client.timeout = 10
                self.client.connect('localhost', 6600)
                connected = True
            except ConnectionError:
                self.main.log.write(log.ERROR, "[MPDIdler]: Failed to "
                                               "connect! -- retrying...")
                time.sleep(0.5)
                pass
            if connected:
                return

    def run(self):
        """Loop and read MPD events, until main wants to exit.

        Read of events is blocking, so a fake event has to be sent, after main
        wanted to exit.
        """

        try:

            self.connect()

            while self.main.keep_run:

                try:
                    res = self.client.idle()
                    self.queue_lock.acquire()
                    self.queue.put(res)
                    self.queue_lock.release()
                except ConnectionError:
                    self.connect()
                    pass

            self.client.disconnect()
            self.main.log.write(log.MESSAGE, "[THREAD] MPD Idler leaving...")

        except ConnectionError:
            # Failed on disconnect.
            pass
        # catch any exceptions here and pass them to the main thread.
        except Exception:
            self.main.ex_queue.put(sys.exc_info())
            pass


class MPC:
    """Send commands to MusicPlayer Daemon and manage idler loop.
    """

    def __init__(self, main):
        self.main = main
        self.client = None
        self.queue = queue.Queue()
        self.queue_lock = threading.Lock()
        self.idler = MPDIdler(self.main, self.queue, self.queue_lock)

    def connect(self):
        """Connect to MPD, retry 5 times, than raise.
        """

        self.idler.start()
        connected = False
        for i in range(5):
            try:
                self.client = MPDClient()
                self.client.timeout = 10
                self.client.connect('localhost', 6600)
                connected = True
            except ConnectionError:
                time.sleep(0.5)
                pass
            if connected:
                return

        raise Exception("Failed to connect to MPD!")

    def process_idler_events(self):
        """Check if idler thread got any events and process them."""
        if self.queue.empty():
            return

        self.queue_lock.acquire()
        try:
            event = self.queue.get_nowait()
        except queue.Empty:
            self.queue_lock.release()
            return
        self.queue_lock.release()

        self.main.log.write(log.MESSAGE, "[MPD event]: %s" % event)

    def join(self):
        """Join all button threads after keep_run in root is False.
        """
        # This is a dirty hack.
        # join() is called after main loop left in PyBlaster.
        # The loop in MPDIdler should exit now, but would hang in idle().
        # So we trigger some mpd command to wake up the idler and MPDIdler
        # thread can exit.
        self.update_database()
        self.idler.join(10)

    def update_database(self):
        """Trigger mpd update command (!= rescan).
        Idler will get notified when scan is done.
        """
        self.client.update()

    def volume(self):
        int(self.client.status()['volume'])

    def change_volume(self, amount):
        vol = self.volume() + amount
        if vol < 0:
            vol = 0
        if vol > 100:
            vol = 100
        self.client.setvol(vol)

    def exit_client(self):
        """Disconnect from mpc

        Call after join(), short before end of program
        """
        self.client.disconnect()

