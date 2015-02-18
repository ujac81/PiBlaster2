

import QtQuick 2.2
import QtBluetooth 5.3

Item {
    property int msgid: 1

    BluetoothSocket {
        id: socket
        connected: true  // property will not return true until connected

        onSocketStateChanged: {
            console.log("New BT Socket State: "+state)

            // TODO: react on state

            if ( connected ) {
                // send password
                sendSingle("1234");
            }
        }
        onStringDataChanged: {
            var data = socket.stringData;
            data = data.substring(0, data.indexOf('\n'));

            // string data seems to change to empty after each send.
            if ( data.length == 0 ) { return; }

            btMessages.bufferLine(data);

            // tell PyBlaster to send next line
            socket.stringData = '1';
        }

        onErrorChanged: {
            console.log("BS: error: "+error);
        }

        // Pad number with zeros.
        // Required for message head (four decimals required).
        function fillZeroes(num, len) {
            var str = String(num);
            while (str.length < len) {
                str = '0' + str;
            }
            return str;
        }

        function sendSingle(cmd) {

            if ( ! connected ) { return; }

            var line = msgid+" 0 "+cmd;
            msgid += 1;
            var head = fillZeroes(line.length, 4);
            var send = head+line;
            console.log("SENDING: "+send);
            socket.stringData = send;
        }
    }


    // Send "keepalive" signal every 10s.
    Timer {
        interval: 5000
        running: true
        repeat: true
        // sendSingle() will check if connected.
        onTriggered: socket.sendSingle("keepalive")
    }


    function setService(service) { socket.setService(service); }

}
