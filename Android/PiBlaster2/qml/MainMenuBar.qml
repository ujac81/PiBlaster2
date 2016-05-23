
import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.3
import Qt.labs.settings 1.0

import "UI.js" as UI

MenuBar {

    id: mainMenuBar


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
        MenuItem {
            text: "Power off"
            onTriggered: UI.btSendSingle('poweroff')
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
            text: "Less bass"
            onTriggered: UI.btSendSingle("setequalstatus lessbass");
        }
        MenuItem {
            text: "Lesser bass"
            onTriggered: UI.btSendSingle("setequalstatus lesserbass");
        }
        MenuItem {
            text: "More mid"
            onTriggered: UI.btSendSingle("setequalstatus moremid");
        }
        MenuItem {
            text: "Less mid"
            onTriggered: UI.btSendSingle("setequalstatus lessmid");
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
            text: "Play now"
            onTriggered: stackView.playlist_action("play_now")
        }
        MenuItem {
            text: "Scroll to start"
            onTriggered: stackView.playlist_action("scroll_start")
        }
        MenuItem {
            text: "Scroll to current"
            onTriggered: stackView.playlist_action("scroll_now")
        }
        MenuItem {
            text: "Scroll to end"
            onTriggered: stackView.playlist_action("scroll_end")
        }
        MenuItem {
            text: "Select all"
            onTriggered: stackView.playlist_action("select_all")
        }
        MenuItem {
            text: "Deselect all"
            onTriggered: stackView.playlist_action("deselect_all")
        }
        MenuItem {
            text: "Invert selection"
            onTriggered: stackView.playlist_action("invert_selection")
        }
        MenuItem {
            text: "Delete selection"
            onTriggered: stackView.playlist_action("delete_selection")
        }
        MenuItem {
            text: "Move selection after current"
            onTriggered: stackView.playlist_action("selection_after_current")
        }
        MenuItem {
            text: "Move selection to end"
            onTriggered: stackView.playlist_action("selection_to_end")
        }
        MenuItem {
            text: "Randomize whole playlist"
            onTriggered: UI.btSendSingle("plshuffle");
        }
        MenuItem {
            text: "Randomize playlist after current"
            onTriggered: UI.btSendSingle("plrandomizeremain");
        }
        MenuItem {
            text: "Clear Playlist"
            onTriggered: UI.btSendSingle("plclear");
        }
    }

    ////////////////////// BROWSE //////////////////////
    Menu {
        id: browseMenu
        title: "Browse"
        enabled: false

         MenuItem {
            text: "Scroll to start"
            onTriggered: stackView.browse_action("scroll_start")
        }
        MenuItem {
             text: "Scroll to end"
             onTriggered: stackView.browse_action("scroll_end")
         }
        MenuItem {
            text: "Select all"
            onTriggered: stackView.browse_action("select_all")
        }

        MenuItem {
            text: "Select all"
            onTriggered: stackView.browse_action("select_all")
        }
        MenuItem {
            text: "Deselect all"
            onTriggered: stackView.browse_action("deselect_all")
        }
        MenuItem {
            text: "Invert selection"
            onTriggered: stackView.browse_action("invert_selection")
        }
        MenuItem {
            text: "Add selection after current"
            onTriggered: stackView.browse_action("selection_after_current")
        }
        MenuItem {
            text: "Add selection at end"
            onTriggered: stackView.browse_action("selection_to_end")
        }
        MenuItem {
            text: "Update Database"
            onTriggered: UI.btSendSingle("update");
        }
    }

    ////////////////////// SEARCH //////////////////////
    Menu {
        id: searchMenu
        title: "Search"
        enabled: false

       MenuItem {
           text: "Scroll to start"
           onTriggered: stackView.search_action("scroll_start")
       }
       MenuItem {
            text: "Scroll to end"
            onTriggered: stackView.search_action("scroll_end")
        }
        MenuItem {
            text: "Select all"
            onTriggered: stackView.search_action("select_all")
        }
        MenuItem {
            text: "Deselect all"
            onTriggered: stackView.search_action("deselect_all")
        }
        MenuItem {
            text: "Invert selection"
            onTriggered: stackView.search_action("invert_selection")
        }
        MenuItem {
            text: "Selection after current"
            onTriggered: stackView.search_action("selection_after_current")
        }
        MenuItem {
            text: "Selection to end"
            onTriggered: stackView.search_action("selection_to_end")
        }
    }

    ////////////////////// UPLOAD //////////////////////
    Menu {
        id: uploadMenu
        title: "Upload"
        enabled: false

        MenuItem {
            text: "Scroll to start"
            onTriggered: stackView.upload_action("scroll_start")
        }
        MenuItem {
             text: "Scroll to end"
             onTriggered: stackView.upload_action("scroll_end")
         }
        MenuItem {
            text: "Select all"
            onTriggered: stackView.upload_action("select_all")
        }
        MenuItem {
            text: "Deselect all"
            onTriggered: stackView.upload_action("deselect_all")
        }
        MenuItem {
            text: "Invert selection"
            onTriggered: stackView.upload_action("invert_selection")
        }
        MenuItem {
            text: "Upload selection"
            onTriggered: stackView.upload_action("upload")
        }
    }




    ////////////////////// FUNCTIONS //////////////////////


    function set_menu(tabname) {
        set_default();

        playlistMenu.enabled = tabname === "PlayListPage";
        browseMenu.enabled = tabname === "BrowsePage";
        searchMenu.enabled = tabname === "SearchPage";
        uploadMenu.enabled = tabname === "UploadPage";
    }


    function set_default() {
        mainMenu.enabled = true;
        equalstatusMenu.enabled = true;
        playMenu.enabled = true;
        playlistMenu.enabled = false;
        browseMenu.enabled = false;
        searchMenu.enabled = false;
        uploadMenu.enabled = false;
    }

    function popupMenu(menuname) {
        if (menuname === "browse") {
            browseMenu.popup();
        }
        else if (menuname === "playlist") {
            playlistMenu.popup();
        }
        else if (menuname === "search") {
            searchMenu.popup();
        }
        else if (menuname === "upload") {
            uploadMenu.popup();
        }
        else {
            console.log("Illegal menuname "+menuname);
        }
    }
}
