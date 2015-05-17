
import QtQuick 2.2

import "../items"
import "../UI.js" as UI

Item {
    id: root
    width: parent.width
    height: 88


    Rectangle {
        anchors.fill: parent
        color: "orange"
        visible: active && ! selected
    }


    Rectangle {
        anchors.fill: parent
        color: "blue"
        visible: ! active && selected
    }

    Rectangle {
        anchors.fill: parent
        color: "cyan"
        visible: active && selected
    }


    Rectangle {
        anchors.fill: parent
        color: "#0fffffff"
        visible: id % 2 == 0 && ! active
    }


    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        color: "white"
        font.pixelSize: 24
        anchors.margins: 10
        anchors.left: parent.left
        anchors.top: parent.top
        text: title
        width: parent.width - 120
        elide: Text.ElideRight
    }

    Text {
        color: "white"
        font.pixelSize: 24
        anchors.margins: 10
        anchors.right: parent.right
        anchors.top: parent.top
        text: length
        width: 80
        elide: Text.ElideRight
    }

    Text {
        color: "white"
        font.pixelSize: 16
        anchors.margins: 10
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: artist
        width: parent.width / 2 - 20
        elide: Text.ElideRight
    }

    Text {
        color: "white"
        font.pixelSize: 16
        anchors.margins: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: album
        width: parent.width / 2 - 20
        elide: Text.ElideRight
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        height: 1
        color: "#424246"
    }


    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            var elem = playlistview.model.get(index);
            elem.selected = ! selected;
        }

        onPressAndHold: {
            UI.btSendSingle("playpos "+position);
            var elem = playlistview.model.get(index);
            elem.selected = false;
        }
    }
}
