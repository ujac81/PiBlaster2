
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0

import "bluetooth"
import "content"
import "dialogs"
import "play"

ApplicationWindow {
    id: main
    visible: true
    width: 800
    height: 1280

    property string color1: "#94d9ff"
    property int lastBTDeviceState: 0
    property bool btconnected: false
    property bool btconnecting: false
    property string statustext: ""

    property string btmac: "00:1A:7D:DA:71:14"
    property bool btautoconnect: false
    property string btpin: "1234"

    property bool playPlaying: false
    property bool playRepeat: false
    property bool playShuffle: false

    property string playSong: "SuperSongName EXTREM LONG SuperSongName LONGER SuperSongName ..."
    property string playArtist: "No Artist"
    property string playAlbum: "No Album"
    property int playLength: 0
    property int playPosition: 0
    property int playVolume: 50
    property int playMixerVolume: 50
    property int playAmpVolume: 50


    Settings {
        id: settings
        property alias btmac: main.btmac
        property alias btautoconnect: main.btautoconnect
        property alias btpin: main.btpin
    }


    NoBluetoothDialog { id: diagNoBluetooth }
    BluetoothCommand { id: btCmd }


    Rectangle {
        color: "#212126"
        anchors.fill: parent
    }

    statusBar: BorderImage {
        border.top: 8
        source: "/images/statusbar.png"
        width: parent.width
        height: main.statustext != "" ? 50 : 0
        Behavior on height {
            NumberAnimation {
                easing.type: Easing.OutCubic;
                duration: 500
            }
        }
        Text {
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            text: main.statustext
        }
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
            font.pixelSize: 38
            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
            x: backButton.x + backButton.width + 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            text: "PiBlaster Remote 2.0"
            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop()
            }
        }
    }

    ListModel {
        id: pageModel
        ListElement {
            title: "Connect"
            page: "connect/ConnectPage.qml"
        }
        ListElement {
            title: "Play"
            page: "play/PlayPage.qml"
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

        btMessages.receivedMessage.connect(btCmd.processMessage);
        btService.bluetoothMessage.connect(bt_message);
        btService.bluetoothError.connect(bt_error);
        btService.bluetoothWarning.connect(bt_warning);
        btService.bluetoothModeChanged.connect(bt_devstate);
        btService.bluetoothConnected.connect(bt_connected);
        btService.bluetoothDisconnected.connect(bt_disconnected);
        main.setStatus("PiBlaster 2 remote loaded.");

        if (btService.hostMode() === 1 && main.btautoconnect) {
            console.log("Found active bluetooth on startup -- autoconnecting...");
            bt_reconnect();
        }
    }


    function bt_reconnect() {
        console.log("SCANNING...");
        btService.serviceSearch(main.btmac);
        main.btconnecting = true;
        main.btconnected = false;
    }
    function bt_disconnect() {
        console.log("DISCONNECTING...");
        btService.disconnectService();
        main.btconnecting = false;
        main.btconnected = false;
    }


    function bt_message(msg) {
        console.log("BT SERVICE MESSAGE: "+msg);
        main.setStatus("Bluetooth: "+msg);
    }

    // Raise no bluetooth dialog if bluetooth adapter lost.
    // App will exit if button on dialog clicked.
    // Connected to BTService::bluetoothModeChanged().
    function bt_devstate(state) {
        console.log("BT DEVICE STATE: "+state);
        if (state === 0 && lastBTDeviceState === 1) {
            diagNoBluetooth.open();
        }
        if (lastBTDeviceState === 0 && state === 1 && main.btautoconnect) {
            console.log("Bluetooth activated -- autoconnecting...");
            bt_reconnect();
        }
        lastBTDeviceState = state;
    }

    // Set error message for failure dialog and raise dialog.
    // App will exit after dialog.
    function bt_error(error) {
        main.btautoconnect = false;
        diagNoBluetooth.service_error(error);
    }

    // Set warning message for failure dialog and raise dialog.
    function bt_warning(warning) {
        diagNoBluetooth.service_warning(warning);
    }

    function bt_connected() {
        btService.writeSocket(main.btpin);
        main.btconnected = true;
        main.btconnecting = false;
        keepalive.running = true;
    }

    function bt_disconnected() {
        console.log("Disconnected...");
        main.btconnected = false;
        main.btconnecting = false;
        keepalive.running = false;
    }

    // Send "keepalive" signal every 10s.
    Timer {
        id: keepalive
        interval: 5000
        running: false
        repeat: true
        // sendSingle() will check if connected.
        onTriggered: btService.writeSocket("keepalive");
    }


    function setStatus(msg) {
        main.statustext = msg;
        deletestatus.restart();
    }

    Timer {
        id: deletestatus
        interval: 3000
        running: false
        repeat: false
        onTriggered: main.statustext = "";
    }


    function btSendSingle(cmd) {
        if (main.btconnected) {
            btService.writeSocket(cmd);
        } else {
            main.setStatus("Not connected to PiBlaster!");
        }
    }

}
