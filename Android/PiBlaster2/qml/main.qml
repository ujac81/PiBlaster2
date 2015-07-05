


import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

import "content"
import "dialogs"
import "play"

import "UI.js" as UI
import "BT.js" as BT


ApplicationWindow {

    property int dp: Screen.pixelDensity

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

    ////////////////////// SETTING //////////////////////

    Settings {
        id: settings
        property alias btmac: main.btmac
        property alias btautoconnect: main.btautoconnect
        property alias btpin: main.btpin
    }

    ////////////////////// DIALOGS //////////////////////


    NoBluetoothDialog { id: diagNoBluetooth }

    ////////////////////// BACKGROUND //////////////////////


    Rectangle {
        color: "#212126"
        anchors.fill: parent
    }

    ////////////////////// MENU //////////////////////

    menuBar: MainMenuBar { id: mainMenuBar }

    ////////////////////// TOP TOOL BAR //////////////////////

    toolBar: ToolBar {
        height: 80

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

    ////////////////////// BOTTOM STATUS BAR //////////////////////

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

    ////////////////////// STACK LIST MODEL //////////////////////


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
            title: "Playlist"
            page: "playlist/PlayListPage.qml"
        }
        ListElement {
            title: "Browse"
            page: "browse/BrowsePage.qml"
        }
        ListElement {
            title: "Search"
            page: "search/SearchPage.qml"
        }
        ListElement {
            title: "Upload"
            page: "upload/UploadPage.qml"
        }
    }

    ////////////////////// STACK VIEW ELEMENT //////////////////////

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
                delegate: MainDelegate {
                    text: title
                    requireconnect: title != "Connect"
                    onClicked: stackView.push(Qt.resolvedUrl(page))
                }
            }

            function activated() {
                mainMenuBar.set_menu("main");
            }
        }

        // let current stack page update on load if required.
        onCurrentItemChanged: {
            if ( currentItem ) {
                currentItem.activated();
                mainMenuBar.set_menu(currentItem.objectName);
            }
        }

        function update_status(msg) {
            if (currentItem.objectName === "PlayPage" ) {
                currentItem.update_status(msg);
            }
            if (currentItem.objectName === "PlayListPage" ) {
                currentItem.update_playlistposition(msg);
            }
        }

        function update_list_status(msg) {
            if (currentItem.objectName === "PlayListPage" ) {
                currentItem.update_playlist(msg);
            }
        }

        function update_browse(msg) {
            if (currentItem.objectName === "BrowsePage") {
                currentItem.update_browse(msg);
            }
        }

        function update_search(msg) {
            if (currentItem.objectName === "SearchPage") {
                currentItem.update_search(msg);
            }
        }

        function update_upload(msg) {
            if (currentItem.objectName === "UploadPage") {
                currentItem.update_upload(msg);
            }
        }

        function playlist_action(action_name) {
            if (currentItem.objectName === "PlayListPage" ) {
                currentItem.playlist_action(action_name)
            }
        }

        function browse_action(action_name) {
            if (currentItem.objectName === "BrowsePage" ) {
                currentItem.browse_action(action_name)
            }
        }

        function search_action(action_name) {
            if (currentItem.objectName === "SearchPage" ) {
                currentItem.search_action(action_name)
            }
        }
        function upload_action(action_name) {
            if (currentItem.objectName === "UploadPage" ) {
                currentItem.upload_action(action_name)
            }
        }

        function show_main() {
            if (stackView.depth > 1) {
                stackView.pop();
            }
        }
    }

    ////////////////////// ONLOAD //////////////////////


    Component.onCompleted: {
        // Incomming commands are bufferd by BTMessageHandler.cpp
        // and emitted as signal when received completely.
        // Process them inside extra file BluetoothCommand.

        btMessages.receivedMessage.connect(BT.processMessage);
        btService.bluetoothMessage.connect(UI.bt_message);
        btService.bluetoothError.connect(UI.bt_error);
        btService.bluetoothWarning.connect(UI.bt_warning);
        btService.bluetoothModeChanged.connect(UI.bt_devstate);
        btService.bluetoothPaired.connect(UI.bt_paired);
        btService.bluetoothConnected.connect(UI.bt_connected);
        btService.bluetoothDisconnected.connect(UI.bt_disconnected);
        UI.setStatus("PiBlaster 2 remote loaded.");

        if (btService.hostMode() === 1 && main.btautoconnect) {
            console.log("Found active bluetooth on startup -- autoconnecting...");
            UI.bt_reconnect();
        }



        console.log(UI.dp(1));
        console.log(UI.dp(10));
        console.log(1*dp);
        console.log(10*dp);
    }




    ////////////////////// TIMERS //////////////////////

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
