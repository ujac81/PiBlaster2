
import QtQuick 2.2
import QtQuick.Controls 1.2

import "bluetooth"
import "content"
import "dialogs"

ApplicationWindow {
    id: main
    visible: true
    width: 800
    height: 1280

    property string color1: "#94d9ff"
    property int lastBTDeviceState: 0
    property int btconnected: 0

    NoBluetoothDialog { id: diagNoBluetooth }


//    BluetoothConnect { id: btConn }
//    BluetoothComm { id: btComm }
//    BluetoothCommand { id: btCmd }

    Rectangle {
        color: "#212126"
        anchors.fill: parent
    }

    toolBar: BorderImage {
        border.bottom: 8
        source: "/images/toolbar.png"
        width: parent.width
        height: 100

        Rectangle {
            id: backButton
            width: opacity ? 60 : 0
            anchors.left: parent.left
            anchors.leftMargin: 20
            opacity: stackView.depth > 1 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            height: 60
            radius: 4
            color: backmouse.pressed ? "#222" : "transparent"
            Behavior on opacity { NumberAnimation{} }
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "/images/navigation_previous_item.png"
            }
            MouseArea {
                id: backmouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: stackView.pop()
            }
        }

        Text {
            font.pixelSize: 42
            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
            x: backButton.x + backButton.width + 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            text: "PiBlaster Remote 2.0"
        }
    }

    ListModel {
        id: pageModel
        ListElement {
            title: "Connect"
            page: "connect/ConnectPage.qml"
        }
        ListElement {
            title: "Buttons"
            page: "content/ButtonPage.qml"
        }
        ListElement {
            title: "Sliders"
            page: "content/SliderPage.qml"
        }
        ListElement {
            title: "ProgressBar"
            page: "content/ProgressBarPage.qml"
        }
        ListElement {
            title: "Tabs"
            page: "content/TabBarPage.qml"
        }
        ListElement {
            title: "TextInput"
            page: "content/TextInputPage.qml"
        }
        ListElement {
            title: "List"
            page: "content/ListPage.qml"
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        // Implements back key navigation
        focus: true
        Keys.onReleased: if (event.key === Qt.Key_Back && stackView.depth > 1) {
                             stackView.pop();
                             event.accepted = true;
                         }

        initialItem: Item {
            width: parent.width
            height: parent.height
            ListView {
                model: pageModel
                anchors.fill: parent
                delegate: AndroidDelegate {
                    text: title
                    onClicked: stackView.push(Qt.resolvedUrl(page))
                }
            }
        }
    }


    Component.onCompleted: {
        // Incomming commands are bufferd by BTMessageHandler.cpp
        // and emitted as signal when received completely.
        // Process them inside extra file BluetoothCommand.
//        btMessages.receivedMessage.connect(btCmd.processMessage);
//        btService.checkBluetoothOn();
        btService.bluetoothMessage.connect(bt_message);
        btService.bluetoothError.connect(bt_error);
        btService.bluetoothModeChanged.connect(bt_devstate);
        btService.bluetoothConnected.connect(bt_connected);
        btService.bluetoothDisconnected.connect(bt_disconnected);

    }


    function bt_reconnect() {
        console.log("SCANNING...");
        btService.serviceSearch("00:1A:7D:DA:71:14");
    }
    function bt_disconnect() {
        console.log("DISCONNECTING...");
        btService.disconnectService();
    }


    function bt_message(msg) {
        console.log("BT SERVICE MESSAGE: "+msg)
    }

    // Raise no bluetooth dialog if bluetooth adapter lost.
    // App will exit if button on dialog clicked.
    // Connected to BTService::bluetoothModeChanged().
    function bt_devstate(state) {
        console.log("BT DEVICE STATE: "+state);
        if (state === 0 && lastBTDeviceState === 1) {
            diagNoBluetooth.open();
        }
        lastBTDeviceState = 1;
    }

    // Set error message for failure dialog and raise dialog.
    // App will exit after dialog.
    function bt_error(error) {
        diagNoBluetooth.service_error(error);
    }

    function bt_connected() {
        btService.writeSocket( "1234" );
        main.btconnected = 1;
    }

    function bt_disconnected() {
        console.log("Disconnected...");
        main.btconnected = 0
    }

    // Send "keepalive" signal every 10s.
    Timer {
        interval: 5000
        running: true
        repeat: true
        // sendSingle() will check if connected.
        onTriggered: {
            if ( main.btconnected === 1 ) {
                btService.writeSocket("keepalive");
            }
        }
    }

}
