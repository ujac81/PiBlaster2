
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

ScrollView {

    objectName: "PlayListPage"

    width: parent.width
    height: parent.height

    flickableItem.interactive: true

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
        UI.btSendSingle("playlistinfocurrent 100");
    }


    function update_playlist(msg) {
        console.log("update_playlist");
        playlistview.model.received_playlist(msg);
    }
}
