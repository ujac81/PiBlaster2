"""usbdrive.py -- Scan connected usb drives and upload

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

import queue
import os
import shutil
import time
import threading

import log


class CopyThread(threading.Thread):
    """

    """

    def __init__(self, main, in_queue, out_queue, in_queue_lock,
                 out_queue_lock):
        """

        :param main:
        :param in_queue:
        :param out_queue:
        :param in_queue_lock:
        :param out_queue_lock:
        :return:
        """

        threading.Thread.__init__(self)

        self.main = main
        self.in_queue = in_queue
        self.out_queue = out_queue
        self.in_queue_lock = in_queue_lock
        self.out_queue_lock = out_queue_lock

    def run(self):
        """
        """

        while self.main.keep_run:

            # dry run outgoing queue on new connection
            while not self.out_queue.empty():
                try:
                    self.out_queue_lock.acquire()
                    upload = self.out_queue.get_nowait()
                    self.out_queue_lock.release()

                    self.upload(upload)

                except queue.Empty:
                    pass

            time.sleep(0.05)  # read each 50 ms

        self.main.log.write(log.MESSAGE,
                            '[THREAD] Uploader leaving...')

    def upload(self, path):
        """

        :param path:
        :return:
        """

        collect_files = self.collect_files(path)

        self.main.led.set_led_yellow(1)

        # Sum up byte size for upload

        sum_size = 0
        for f in collect_files:
            try:
                sum_size += os.path.getsize(f)
            except OSError:
                # lost file, do not sum it -- lost drive?
                pass

        self.main.led.set_led_yellow(0)

        # check free disk space

        s = os.statvfs('/local/upload')
        free = s.f_bavail * s.f_frsize

        if sum_size > free - 1024 * 1024 * 200:
            # keep at least 200MB (logs, cache, whatever)
            self.main.log.write(log.MESSAGE,
                                "[UPLOADER] Not uploading %s -- insufficient "
                                "disk space" % path)
            return

        # perform upload

        self.main.log.write(log.MESSAGE,
                            '[UPLOADER] Uploading... %s' % path)

        i = 0
        for f in collect_files:

            # remove '/media/usbX/'
            rel = os.sep.join(f.split(os.sep)[3:])
            dest = os.path.join('/local/upload', rel)

            # check if exists
            if os.path.isfile(dest):
                continue

            # check dir exists
            dirname = os.path.dirname(dest)
            if not os.path.isdir(dirname):
                try:
                    os.makedirs(dirname)
                except OSError:
                    # TODO: do something
                    pass

            # perform copy
            print("COPY: %s -> %s" % (f, dest))

            try:
                shutil.copy(f, dest)
            except IOError:
                # TODO: do something
                pass

            self.main.led.set_led_yellow(i % 2)
            i += 1

            if not self.main.keep_run:
                return

        self.main.led.set_led_yellow(0)

        # Flash some LED
        for i in range(5):
            self.main.led.flash_led(i, 1)
        time.sleep(2)
        for i in range(5):
            self.main.led.flash_led(i, 1)

        self.main.log.write(log.MESSAGE, '[UPLOADER] Upload done.')

    def collect_files(self, path):
        """

        :param path:
        :return:
        """

        if path is None:
            return []

        if os.path.isfile(path):
            return [path]

        mp3s = [os.path.join(d, f)
                for d, subd, files in os.walk(path)
                for f in files if f.endswith((".mp3", ".ogg", ".flac"))]

        return mp3s


class UsbDrive:

    def __init__(self, main):
        """Generate queues and uploader
        """

        self.main = main

        self.in_queue = queue.Queue()
        self.out_queue = queue.Queue()
        self.in_queue_lock = threading.Lock()
        self.out_queue_lock = threading.Lock()

        self.upload_thread = CopyThread(self.main,
                                        self.in_queue, self.out_queue,
                                        self.in_queue_lock,
                                        self.out_queue_lock)

    def start_uploader_thread(self):
        self.upload_thread.start()

    def join(self):
        self.upload_thread.join()

    def browse_path(self, path):
        """

        :param path:
        :return:
        """

        self.main.log.write(log.DEBUG1, '[USB] Browse: %s' % path)

        res = []

        if path == '/':
            for usb in os.listdir('/media'):
                if usb != 'usb':
                    # skip double entry usb, usb0
                    res += self.dir_listing(os.path.join('/media', usb))
        else:
            res = self.dir_listing(path)

        return res

    def dir_listing(self, path):
        """

        :param path:
        :return:
        """
        res = []

        try:
            listing = os.listdir(path)
        except OSError:
            listing = []
            pass

        dirs = [d for d in listing if os.path.isdir(os.path.join(path, d))]
        files = [f for f in listing
                 if os.path.isfile(os.path.join(path, f))
                 and f.endswith(('.mp3', '.flac', '.ogg'))]

        for d in dirs:
            res.append(['1', d, os.path.join(path, d)])

        for f in files:
            res.append(['2', f, os.path.join(path, f)])

        return res

    def queue_upload(self, payload):
        """

        :param payload:
        :return:
        """

        if payload is None:
            return

        for i in payload:
            self.main.log.write(log.DEBUG1, "[UPLOAD] queue: %s" % i)
            self.out_queue_lock.acquire()
            self.out_queue.put(i)
            self.out_queue_lock.release()
