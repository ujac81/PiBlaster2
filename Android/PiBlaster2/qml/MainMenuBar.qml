
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.3
import Qt.labs.settings 1.0

import "UI.js" as UI

MenuBar {


    ////////////////////// MAIN //////////////////////
    Menu {
        id: mainMenu
        title: "Main"
        enabled: true

        MenuItem {
            text: "Connect"
            onTriggered: UI.bt_reconnect()
        }
        MenuItem {
            text: "Disconnect"
            onTriggered: UI.bt_disconnect()
        }
        MenuItem {
            text: "Exit"
            onTriggered: Qt.quit()
        }
    }

    ////////////////////// EQUAL //////////////////////
    Menu {
        id: equalstatusMenu
        title: "Equalizer"
        enabled: true

        MenuItem {
            text: "Normal"
            onTriggered: UI.btSendSingle("setequalstatus normal");
        }
        MenuItem {
            text: "Bass"
            onTriggered: UI.btSendSingle("setequalstatus bass");
        }
        MenuItem {
            text: "More bass"
            onTriggered: UI.btSendSingle("setequalstatus morebass");
        }
        MenuItem {
            text: "Max bass"
            onTriggered: UI.btSendSingle("setequalstatus maxbass");
        }
        MenuItem {
            text: "More mid"
            onTriggered: UI.btSendSingle("setequalstatus moremid");
        }
        MenuItem {
            text: "More trebble"
            onTriggered: UI.btSendSingle("setequalstatus moretrebble");
        }
    }

    ////////////////////// PLAY //////////////////////
    Menu {
        id: playMenu
        title: "Play"
        enabled: true

        MenuItem {
            text: "Play"
            onTriggered: UI.btSendSingle("playplay");
        }
        MenuItem {
            text: "Plause"
            onTriggered: UI.btSendSingle("playpause");
        }
        MenuItem {
            text: "Stop"
            onTriggered: UI.btSendSingle("playstop");
        }
        MenuItem {
            text: "Previous"
            onTriggered: UI.btSendSingle("playprev");
        }
        MenuItem {
            text: "Next"
            onTriggered: UI.btSendSingle("playnext");
        }
    }


    ////////////////////// PLAYLIST //////////////////////
    Menu {
        id: playlistMenu
        title: "Playlist"
        enabled: false

        MenuItem {
            text: "Connect"
            onTriggered: UI.bt_reconnect()
        }
        MenuItem {
            text: "Disconnect"
            onTriggered: UI.bt_disconnect()
        }
        MenuItem {
            text: "Exit"
            onTriggered: Qt.quit()
        }
    }




    ////////////////////// FUNCTIONS //////////////////////


    function set_menu(tabname) {
        set_default();
    }


    function set_default() {
        mainMenu.enabled = true;
        equalstatusMenu.enabled = true;
        playMenu.enabled = true;
        playlistMenu.enabled = false;
    }
}
