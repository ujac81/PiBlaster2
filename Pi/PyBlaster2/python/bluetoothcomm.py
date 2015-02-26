"""bluetoothcomm.py -- Enable RFCOMM server to control PyBlaster via bluetooth

@Author Ulrich Jansen <ulrich.jansen@rwth-aachen.de>
"""

import bluetooth
import queue
import sys
import threading

from codes import *
from codes import *
import cmd
import log

NOTCONNECTED = 0
CONNECTED = 1
AUTHORIZED = 2


class ServerThread(threading.Thread):
    """

    """

    def __init__(self, main, in_queue, out_queue, in_queue_lock,
                 out_queue_lock):
        """
        """

        threading.Thread.__init__(self)

        self.main = main
        self.in_queue = in_queue
        self.out_queue = out_queue
        self.in_queue_lock = in_queue_lock
        self.out_queue_lock = out_queue_lock

        self.mode = NOTCONNECTED
        self.client_sock = None
        self.client_info = None
        self.timeout = 0.1  # socket timeouts for non blocking con.
        self.comm_timeout = 2  # increase timeout on send/recv
        self.timeoutpolls = 200  # disconnect after N inactivity timeouts
        self.nowpolls = 0  # reset after each receive,
        # incremented while waiting for data
        self.cmdbuffer = []  # split incoming commands by lines
        self.server_sock = None
        self.port = 0
        self.uuid = "94f39d29-7d6d-437d-973b-fba39e49d4ee"
        self.next_buffer_size = -1  # set in read_socket to receive lines
        self.msgid = -1  # id counter for messages sent by server (negative)

    def run(self):
        """

        """

        try:

            self.start_server()

            while self.main.keep_run:
                self.read_socket()

                # dry run outgoing queue on new connection
                while not self.out_queue.empty():
                    try:
                        self.out_queue_lock.acquire()
                        out = self.out_queue.get_nowait()
                        self.out_queue_lock.release()

                        self.send_client(msg_id_in=out[0],
                                         status=out[1],
                                         code=out[2],
                                         msg=out[3],
                                         message_list=out[4]
                                         )
                    except queue.Empty:
                        pass

            self.main.log.write(log.MESSAGE,
                                '[THREAD] RFCOMM server leaving...')

        except bluetooth.btcommon.BluetoothError:
            # except Exception:
            self.main.ex_queue.put(sys.exc_info())
            pass

    def start_server(self):
        """Open bluetooth server socket and advertise service
        """

        self.server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)

        self.server_sock.bind(("", bluetooth.PORT_ANY))
        self.server_sock.listen(1)  # max conns
        self.port = self.server_sock.getsockname()[1]

        bluetooth.advertise_service(self.server_sock, "PyBlaster",
                                    service_id=self.uuid,
                                    service_classes=
                                    [self.uuid,
                                     bluetooth.SERIAL_PORT_CLASS],
                                    profiles=[bluetooth.SERIAL_PORT_PROFILE],
                                    )
        self.server_sock.settimeout(self.timeout)
        self.main.log.write(log.MESSAGE, '[BTTHREAD] RFCOMM service opened as '
                                         'PyBlaster')
        self.mode = NOTCONNECTED
        self.msgid = -1

    def read_socket(self):
        """Check if command found in socket

        Called by run loop at every poll.
        """

        if self.mode == NOTCONNECTED:

            try:
                self.client_sock, self.client_info = self.server_sock.accept()
            except bluetooth.btcommon.BluetoothError:
                self.client_sock = None
                self.client_info = None
                pass

            if self.client_sock:
                self.main.log.write(log.MESSAGE,
                                    '[BTTHREAD] Got connection from %s on '
                                    'channel %d' % (self.client_info[0],
                                                    self.client_info[1]))
                self.mode = CONNECTED
                self.client_sock.settimeout(self.timeout)
                self.main.led.set_led_blue()
                self.nowpolls = 0
                self.cmdbuffer = []

                # dry run outgoing queue on new connection
                while not self.out_queue.empty():
                    try:
                        self.out_queue_lock.acquire()
                        self.out_queue.get_nowait()
                        self.out_queue_lock.release()
                    except queue.Empty:
                        pass

        if self.mode == CONNECTED or self.mode == AUTHORIZED:

            self.receive_into_buffer()

            self.nowpolls += 1
            if self.nowpolls > self.timeoutpolls:
                self.main.log.write(log.MESSAGE,
                                    '[BTTHREAD] Connection timed out')
                self.disconnect()

            if self.nowpolls % 500 == 0:
                self.main.log.write(log.DEBUG1, '[BTTHREAD] Timeout poll '
                                                'count %d' % self.nowpolls)

            # dry run buffer if connected
            while len(self.cmdbuffer):
                self.nowpolls = 0
                self.read_command(self.cmdbuffer.pop(0))

    def disconnect(self):
        """Close sockets and restart server

        Called after timeout poll count reached or if connection closed by
        wrong password or on purpose.
        """

        self.mode = NOTCONNECTED
        self.server_sock.close()
        self.client_sock.close()
        self.main.led.set_led_blue(0)
        self.main.log.write(log.MESSAGE, '[BTTHREAD] Closed connection.')
        self.start_server()

    def send_client(self, msg_id_in, status, code, msg, message_list):
        """Send data package to PiBlaster APP via bluetooth

        :param msg_id: message id as received by read_command
        :param status: status from cmd
        :param code: result code to tell PiBlaster APP which data is sent
        :param msg: string message to be displayed at PiBlaster APP
        :param message_list: matrix of payload lines
        """

        if self.mode == NOTCONNECTED:
            return

        # -1 indicates, that message is sent by server without request.
        # Use inner message counter and decrease it (negative ids)
        msg_id = msg_id_in
        if msg_id_in == -1:
            msg_id = self.msgid
            self.msgid -= 1

        self.client_sock.settimeout(self.comm_timeout)
        self.main.led.set_led_white(1)

        self.main.log.write(log.DEBUG1,
                            "DEBUG send: %d || %d || %d || %d || %s" %
                            (msg_id, status, code, len(message_list), msg))

        # send msg header
        # 4 ints [line length, msg_id, status code, payload_len, msg]
        full_msg = '{0:04d}{1:04d}{2:04d}{3:06d}{4:s}'.\
            format(msg_id, status, code, len(message_list), msg)
        send_msg = '{0:06d}{1:s}'.format(len(full_msg), full_msg)

        try:
            self.client_sock.send((send_msg+'\n').encode('utf-8'))
        except bluetooth.btcommon.BluetoothError:
            self.client_sock.settimeout(self.timeout)
            self.main.led.set_led_white(0)
            return

        if not self.recv_ok_byte():
            self.client_sock.settimeout(self.timeout)
            self.main.led.set_led_white(0)
            return

        cluster_size = 40   # pack this many payload lines in one message
        full_send_msg = ''  # cluster messages in a bunch
        cluster_count = 0

        # Send payload as full_send_msg.
        # Cluster every 40 lines in one message and send it.
        for i in range(len(message_list)):
            line = message_list[i]
            # construct line by prefixing each field with its length
            send_line = '{0:04d}{1:02d}'.format(msg_id, len(line))
            for item in line:
                send_line += '{0:03d}'.format(len(item)) + item
            send_msg = '{0:04d}'.format(len(send_line)) + send_line
            full_send_msg += send_msg
            cluster_count += 1

            if cluster_count == cluster_size or i == len(message_list)-1:
                send_msg = 'PL{0:04d}'.format(cluster_count) + \
                           full_send_msg
                full_send_msg = '{0:06d}'.format(len(send_msg)) + \
                                send_msg
                try:
                    self.client_sock.send((full_send_msg+'\n').encode('utf-8'))
                except bluetooth.btcommon.BluetoothError:
                    break
                if not self.recv_ok_byte():
                    break
                cluster_count = 0
                full_send_msg = ''

        self.client_sock.settimeout(self.timeout)
        self.main.led.set_led_white(0)

    def read_command(self, cmd):
        """Evaluate command received from client socket if AUTHORIZED."""

        self.nowpolls = 0

        # message id is first field in command, truncate from rest of command
        cmd_split = cmd.split(' ')
        msg_id = -1
        payload_size = -1
        error_cmd = False
        if len(cmd_split) < 3:
            error_cmd = True
        else:
            try:
                msg_id = int(cmd_split[0])
                payload_size = int(cmd_split[1])
            except ValueError:
                msg_id = -1
                payload_size = -1
                error_cmd = True

        if error_cmd:
            self.main.log.write(log.ERROR,
                                "[ERROR] Protocol error: %s" % cmd)
            return

        cmd = cmd[len(cmd_split[0]) + len(cmd_split[1]) + 2:]
        payload = self.read_rows(payload_size)

        if self.mode != AUTHORIZED:
            # check if password has been sent
            if cmd == self.main.settings.pin1:
                self.mode = AUTHORIZED
                self.main.log.write(log.MESSAGE, "BT AUTHORIZED")
                self.send_client(0, 0, PASS_OK, "Password ok.", [])
            else:
                self.main.log.write(log.MESSAGE, "BT NOT AUTHORIZED")
                self.send_client(0, 0, PASS_ERROR, "Wrong password.", [])
                self.disconnect()
        elif self.mode == AUTHORIZED:
            self.in_queue_lock.acquire()
            self.in_queue.put([msg_id, cmd, payload])
            self.in_queue_lock.release()

    def send_result(self, msg_id, status, code, msg, res_list):
        """
        """
        send_failed = False
        try:
            self.send_client(msg_id, status, code, msg, res_list)
        except bluetooth.btcommon.BluetoothError:
            self.main.log.write(log.ERROR,
                                "Failed to send to client -- "
                                "disconnected? Restarting server...")
            self.disconnect()
            send_failed = True

        if status == cmd.STATUSEXIT or \
                status == cmd.STATUSDISCONNECT:
            if not send_failed:
                # already called if send_failed
                self.main.log.write(log.MESSAGE,
                                    "Got disconnect command.")
                self.disconnect()

    def read_rows(self, count):
        """Read multiple rows from bluetooth socket.

        :param count: number of rows to read from BT
        :returns rows as list or empty list on BT error
        """

        # TODO this may loop forever -- do some max retries or so

        self.main.led.set_led_yellow(1)

        result = []
        while 1:
            if len(result) == count:
                break

            # 1st try to read buffers for pending instructions
            while len(self.cmdbuffer):
                if len(result) == count:
                    break
                result.append(self.cmdbuffer.pop(0))

            if len(result) == count:
                break

            self.receive_into_buffer()

        self.main.led.set_led_yellow(0)

        return result

    def receive_into_buffer(self):
        """

        """
        receiving = True
        while receiving:
            data = None
            # if last package was line head (num bytes), receive msg
            # if head size not set, receive 4 bytes (msg head)
            recv_size = self.next_buffer_size
            if recv_size == -1:
                recv_size = 4
                self.client_sock.settimeout(self.timeout)
            else:
                self.client_sock.settimeout(self.comm_timeout)
            if recv_size > 0:
                try:
                    data = self.client_sock.recv(recv_size).decode(
                        'utf-8').strip()
                except bluetooth.btcommon.BluetoothError:
                    receiving = False
                    pass
            if data and len(data) > 0:
                if self.next_buffer_size == -1:
                    # Skip if received length is != 4, we received a line feed
                    # or some other crap.
                    # Forget this data and keep reading 4 bytes from stream
                    # until new message header found.
                    if len(data) == 4:
                        # we should have received buffer size now
                        try:
                            self.next_buffer_size = int(data)
                        except ValueError:
                            self.main.log.write(log.EMERGENCY,
                                                "[RECV]: Value error in int "
                                                "conversion! Protocol broken?")
                else:
                    # we received data
                    self.cmdbuffer.append(data)
                    self.main.log.write(log.DEBUG3, "---<<< RECV: "+data)
                    self.next_buffer_size = -1

        self.client_sock.settimeout(self.timeout)

    def recv_ok_byte(self):
        """

        """
        self.client_sock.settimeout(self.comm_timeout)
        try:
            self.client_sock.recv(1)
        except bluetooth.btcommon.BluetoothError:
            return False
            pass
        return True


class RFCommServer:
    """Send/recv commands/results via bluetooth channel"""

    def __init__(self, main):
        """Set state to not connected"""

        self.main = main
        self.in_queue = queue.Queue()
        self.out_queue = queue.Queue()
        self.in_queue_lock = threading.Lock()
        self.out_queue_lock = threading.Lock()

        self.server_thread = ServerThread(self.main,
                                          self.in_queue, self.out_queue,
                                          self.in_queue_lock,
                                          self.out_queue_lock)

    def start_server_thread(self):
        self.server_thread.start()

    def join(self):
        self.server_thread.join()

    def check_incomming_commands(self):

        # dry run incomming queue
        while not self.in_queue.empty():
            try:
                self.in_queue_lock.acquire()
                cmd = self.in_queue.get_nowait()
                self.in_queue_lock.release()
                self.send_client([cmd[0]] +
                                 self.main.cmd.eval(cmd[1], 'rfcomm', cmd[2]))
            except queue.Empty:
                pass

    def send_client(self, arr):
        """Put array of [id, status, code, message, payload] to send queue.

        :param arr: [msg_id, status, code, msg, res_list]
        """
        if self.server_thread.mode == AUTHORIZED:
            self.out_queue_lock.acquire()
            self.out_queue.put(arr)
            self.out_queue_lock.release()
