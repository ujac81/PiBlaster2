
import QtQuick 2.2

Item {
    id: root
    width: parent.width
    height: 88


    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        id: textitem
        color: "white"
        font.pixelSize: 32
        text: title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 30
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        height: 1
        color: "#424246"
    }


    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {}
    }
}
