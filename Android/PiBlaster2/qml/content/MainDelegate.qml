

import QtQuick 2.2

Item {
    id: root
    width: parent.width
    height: main.sizeMainItem

    property bool requireconnect
    property alias text: textitem.text
    signal clicked

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        id: textitem
        color: (root.requireconnect && ! main.btconnected) ? "grey" : "white"
        font.pixelSize: main.sizeFontHead
        text: modelData
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: main.sizeFontHead
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: main.sizeFontHead / 2
        height: 1
        color: "#424246"
    }

    Image {
        anchors.right: parent.right
        anchors.margins: main.sizeMargins
        anchors.rightMargin: 2 * main.sizeMargins
        anchors.verticalCenter: parent.verticalCenter
        source: "/images/navigation_next_item.png"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            if (root.requireconnect && ! main.btconnected) {
                // do nothing
            } else {
                root.clicked()
            }
        }

    }
}
