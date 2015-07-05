
import QtQuick 2.2

import "../items"
import "../UI.js" as UI

Item {
    id: root
    width: parent.width
    height: main.sizeListItem


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
        visible: index % 2 == 0 && ! active
    }


    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: dragArea.pressed
    }

    // song title text (top-left)
    Text {
        color: "white"
        font.pixelSize: main.sizeFontListItem
        anchors.margins: main.sizeMargins
        anchors.left: parent.left
        anchors.top: parent.top
        text: title
        width: parent.width - 4*main.sizeFontItem - 4*main.sizeMargins
        elide: Text.ElideRight
    }

    // song length info
    Text {
        color: "white"
        font.pixelSize: main.sizeFontListItem
        anchors.margins: main.sizeMargins
        anchors.right: parent.right
        anchors.top: parent.top
        text: length
        width: 4*main.sizeFontItem
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

    // dark line between items
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: main.sizeMargins
        height: 1
        color: "#424246"
    }


    MouseArea {
        id: dragArea
        property int positionStarted: 0
        property int positionEnded: 0
        property int positionsMoved: Math.floor((positionEnded - positionStarted)/root.height)
        property int newPosition: index + positionsMoved
        property bool held: false
        drag.axis: Drag.YAxis
        anchors.fill: parent
        onClicked: {
            var elem = playlistview.model.get(index);
            elem.selected = ! selected;
        }

        onDoubleClicked: {
            // TODO: open menu here
            UI.btSendSingle("playpos "+position);
            var elem = playlistview.model.get(index);
            elem.selected = false;
        }

        onPressAndHold: {
            root.z = 2;
            positionStarted = root.y;
            dragArea.drag.target = root;
            root.opacity = 0.5
            playlistview.interactive = false;
            held = true;
            drag.maximumY = (playlistscrollview.height - root.height - 1 + playlistview.contentY);
            drag.minimumY = 0;
        }

        onPositionChanged: {
            positionEnded = root.y;
        }

        onReleased: {
            if (Math.abs(positionsMoved) < 1 && held == true) {
                // TODO: better position guess
                root.y = positionStarted;
                root.opacity = 1;
                playlistview.interactive = true;
                dragArea.drag.target = null;
                held = false;
            } else {
                if (held == true) {
                    // TODO: better position guess
                    var moveTo = newPosition;
                    if (newPosition < 1) {
                        moveTo = 0;

                    } else if (newPosition > playlistview.count - 1) {
                        moveTo = playlistview.count - 1;
                    }
                    console.log("Move id "+id+" to index "+newPosition)
                    root.z = 1;
                    playlistview.model.playlist_move(id, moveTo);
                    root.opacity = 1;
                    playlistview.interactive = true;
                    dragArea.drag.target = null;
                    held = false;
                }
            }
        }
    }
}
