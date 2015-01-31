"""lirc.py -- Read remote controller via lirc

"""

import lirc
import queue
import threading
import sys
import time

import log


class LircThread(threading.Thread):
    """

    """

    def __init__(self, main, queue, queue_lock):
        """

        """
        threading.Thread.__init__(self)
        self.main = main
        self.queue = queue
        self.queue_lock = queue_lock
        self.lircsock = None

    def run(self):
        """

        """

        try:

            conf = self.main.settings.defvars['PYBLASTER_LIRC_CONF']
            self.lircsock = lirc.init("pyblaster2", conf, blocking=False)

            while self.main.keep_run:
                read = lirc.nextcode()
                if len(read):
                    self.queue_lock.acquire()
                    self.queue.put(read[0])
                    self.queue_lock.release()
                time.sleep(0.05)  # read each 50 ms

            lirc.deinit()

            self.main.log.write(log.MESSAGE,
                                "[THREAD] Lirc socket leaving...")

        # Forward any exceptions to main thread, so PyBlaster can die.
        except Exception:
            self.main.ex_queue.put(sys.exc_info())
            pass


class Lirc:

    def __init__(self, main):

        self.queue = queue.Queue()
        self.queue_lock = threading.Lock()
        self.main = main
        self.lircthread = LircThread(self.main, self.queue, self.queue_lock)

    def start(self):
        self.lircthread.start()

    def join(self):
        self.lircthread.join(0.1)

    def has_lirc_event(self):
        if not self.queue.empty():
            return True
        return False

    def read_last_lirc_event(self):
        """dry run queue and return last command if such -- None else
        """
        result = None

        while not self.queue.empty():
            self.queue_lock.acquire()
            try:
                result = self.queue.get_nowait()
            except queue.Empty:
                self.queue_lock.release()
                return None
            self.queue_lock.release()

        return result

    def read_lirc(self):

        if not self.has_lirc_event():
            return

        event = self.read_last_lirc_event()
        if event is None:
            return

        self.main.log.write(log.MESSAGE, "--- Lirc \"%s\" pressed" % event)
        self.main.cmd.eval(event, "lirc")
