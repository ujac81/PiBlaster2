
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

ScrollView {

    id: playlistscrollview

    objectName: "PlayListPage"

    width: parent.width
    height: parent.height

    flickableItem.interactive: true
    focus: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Menu) {
            main.popupMenu("playlist");
            event.accepted = true;
        }
    }

    ListView {
        id: playlistview
        anchors.fill: parent
        model: PlayListModel {}
        delegate: PlayListDelegate {}
    }

    style: ScrollViewStyle {
        transientScrollBars: true
        handle: Item {
            implicitWidth: 14
            implicitHeight: 26
            Rectangle {
                color: "#424246"
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.bottomMargin: 6
            }
        }
        scrollBarBackground: Item {
            implicitWidth: 14
            implicitHeight: 26
        }
    }


    function activated() {
        console.log("PLAYLIST ACTIVATED");
        UI.btSendSingle("playlistinfocurrent 0");
    }


    function update_playlist(msg) {
        console.log("update_playlist");
        playlistview.model.received_playlist(msg);
    }

    function update_playlistposition(msg) {
        console.log("update_playlistposition");
        playlistview.model.update_playlistposition(msg);
    }


    function playlist_action(action_name) {
        if (action_name === "play_now") {
            playlistview.model.play_now()
        }
        else if (action_name === "scroll_start") {
            playlistview.positionViewAtBeginning()
        }
        else if (action_name === "scroll_now") {
            playlistview.model.scroll_now()
        }
        else if (action_name === "scroll_end") {
            playlistview.positionViewAtEnd()
        }
        else if (action_name === "select_all") {
            playlistview.model.select_all();
        }
        else if (action_name === "deselect_all") {
            playlistview.model.deselect_all();
        }
        else if (action_name === "invert_selection") {
            playlistview.model.invert_selection();
        }
        else if (action_name === "delete_selection") {
            playlistview.model.process_selection("pldelete");
        }
        else if (action_name === "selection_after_current") {
            playlistview.model.process_selection("plselaftercur");
        }
        else if (action_name === "selection_to_end") {
            playlistview.model.process_selection("plseltoend");
        }
        else {
            console.log("ERROR: illegal action_name "+action_name);
        }

    }
}
