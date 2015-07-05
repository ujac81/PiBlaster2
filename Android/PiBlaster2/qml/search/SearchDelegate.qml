
import QtQuick 2.2

import "../items"
import "../UI.js" as UI

Item {
    id: root
    width: parent.width
    height: main.sizeListItem

    // selected rect
    Rectangle {
        anchors.fill: parent
        color: "blue"
        visible: selected
    }

    // stripe rect
    Rectangle {
        anchors.fill: parent
        color: "#0fffffff"
        visible: index % 2 == 0
    }

    // on pressed rect
    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    // title text
    Text {
        color: "white"
        font.pixelSize: main.sizeFontListItem
        anchors.margins: main.sizeMargins
        anchors.left: parent.left
        anchors.top: parent.top
        text: title
        width: parent.width - 4*main.sizeMargins-4*main.sizeFontListItem
        elide: Text.ElideRight
    }

    // time text
    Text {
        color: "white"
        font.pixelSize: main.sizeFontListItem
        anchors.margins: main.sizeMargins
        anchors.right: parent.right
        anchors.top: parent.top
        text: length
        width: 4*main.sizeFontListItem
        elide: Text.ElideRight
    }

    // artist text
    Text {
        color: "white"
        font.pixelSize: main.sizeFontSubItem
        anchors.margins: main.sizeMargins
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: artist
        width: parent.width / 2 - 2*main.sizeMargins
        elide: Text.ElideRight
    }

    // album text
    Text {
        color: "white"
        font.pixelSize: main.sizeFontSubItem
        anchors.margins: main.sizeMargins
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: album
        width: parent.width / 2 - 2*main.sizeMargins
        elide: Text.ElideRight
    }

    // separator line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: main.sizeMargins
        height: 1
        color: "#424246"
    }


    MouseArea {
        id: mouse
        anchors.fill: parent


        onClicked: {
            var elem = searchview.model.get(index);
            elem.selected = ! selected;
        }

        // TODO: double click = open menu or so
        // TODO: hold click = append or so


    }
}
