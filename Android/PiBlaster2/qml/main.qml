


import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2
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

    property bool playShuffle: false
    property bool playRepeat: false
    property bool playPlaying: false

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

    menuBar: MenuBar {
        Menu {
            title: "Menu1"
            MenuItem { text: "item1" }
            MenuItem { text: "item2" }
            MenuItem { text: "item3" }
            MenuItem { text: "item4" }
        }
    }

    toolBar: ToolBar {
        height: 80

//        style: ToolBarStyle {
////            padding {
////                left: 8
////                right: 8
////                top: 3
////                bottom: 3
////            }
//            background: Rectangle {
//                implicitWidth: 100
//                implicitHeight: 80
//                border.color: "#33B5E5"
//                color: "#020203"
//                opacity: 0.5
////                gradient: Gradient {
////                    GradientStop { position: 0 ; color: "#fff" }
////                    GradientStop { position: 1 ; color: "#eee" }
////                }
//            }
//        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
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
                font.pixelSize: 30
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
            Item { Layout.fillWidth: true }
        }
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

//    toolBar: BorderImage {
//        border.bottom: 8
//        source: "/images/toolbar.png"
//        width: parent.width
//        height: 100

//        Rectangle {
//            id: backButton
//            width: opacity ? 60 : 0
//            anchors.left: parent.left
//            anchors.leftMargin: 20
//            opacity: stackView.depth > 1 ? 1 : 0
//            anchors.verticalCenter: parent.verticalCenter
//            antialiasing: true
//            height: 60
//            radius: 4
//            color: backmouse.pressed ? "#222" : "transparent"
//            Behavior on opacity { NumberAnimation{} }
//            Image {
//                anchors.verticalCenter: parent.verticalCenter
//                source: "/images/navigation_previous_item.png"
//            }
//            MouseArea {
//                id: backmouse
//                anchors.fill: parent
//                anchors.margins: -10
//                onClicked: stackView.pop()
//            }
//        }

//        Text {
//            font.pixelSize: 38
//            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
//            x: backButton.x + backButton.width + 20
//            anchors.verticalCenter: parent.verticalCenter
//            color: "white"
//            text: "PiBlaster Remote 2.0"
//            MouseArea {
//                anchors.fill: parent
//                onClicked: stackView.pop()
//            }
//        }
//    }


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
            objectName: "InitialItem"
            width: parent.width
            height: parent.height
            ListView {
                id: mainListView
                model: pageModel
                anchors.fill: parent
                delegate: AndroidDelegate {
                    text: title
                    onClicked: stackView.push(Qt.resolvedUrl(page))
                }
            }

            function activated() {}
        }

        // let current stack page update on load if required.
        onCurrentItemChanged: {
            if ( currentItem ) {
                console.log("=== Stack item changed ===");
                currentItem.activated();
            }
        }

        function update_status(msg) {
            if (currentItem.objectName === "PlayPage" ) {
                currentItem.update_status(msg);
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
        main.btautoconnect = true;
    }

    function bt_disconnected() {
        console.log("Disconnected...");
        main.btconnected = false;
        main.btconnecting = false;
        keepalive.running = false;
    }

    function btSendSingle(cmd) {
        if (main.btconnected) {
            // reset keep alive to prevent interference with command sending.
            keepalive.running = false;
            keepalive.running = true;
            btService.writeSocket(cmd);
        } else {
            main.setStatus("Not connected to PiBlaster!");
        }
    }

    function setStatus(msg) {
        main.statustext = msg;
        deletestatus.restart();
    }

    // Send "keepalive" signal every 10s.
    Timer {
        id: keepalive
        interval: 10000
        running: false
        repeat: true
        // sendSingle() will check if connected.
        onTriggered: btService.writeSocket("keepalive");
    }

    Timer {
        id: deletestatus
        interval: 3000
        running: false
        repeat: false
        onTriggered: main.statustext = "";
    }


}
