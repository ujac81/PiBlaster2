
import QtQuick 2.2

import "../items"
import "../UI.js" as UI

Item {
    id: root
    width: parent.width
    height: main.sizeListItem

    Rectangle {
        anchors.fill: parent
        color: "blue"
        visible: selected
    }

    Rectangle {
        anchors.fill: parent
        color: "#0fffffff"
        visible: index % 2 == 0
    }

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        color: "white"
        font.pixelSize: main.sizeFontListItem
        anchors.margins: main.sizeMargins
        anchors.left: parent.left
        anchors.top: parent.top
        text: title
        width: parent.width - main.sizeMargins
        elide: Text.ElideRight
    }

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
            if (ftype !== 0) {
                var elem = uploadview.model.get(index);
                elem.selected = ! selected;
            }
        }

        onDoubleClicked: {
            if (ftype === 0 || ftype === 1) {
                uploadscrollview.send_browse(file);
            }
        }

        onPressAndHold: {

        }
    }
}
