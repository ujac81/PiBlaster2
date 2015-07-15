
import QtQuick 2.2

import "../items"
import "../UI.js" as UI

Item {
    id: root
    width: parent.width
    height: main.sizeListItem

    // seleced rect
    Rectangle {
        anchors.fill: parent
        color: "blue"
        visible: selected
    }

    // striped rect
    Rectangle {
        anchors.fill: parent
        color: "#0fffffff"
        visible: index % 2 == 0
    }

    // line between items
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: main.sizeMargins
        height: 1
        color: "#424246"
    }

    // load displaying component
    Loader {
        anchors.fill: parent
        sourceComponent: ftype == 0 ? upItem : (ftype == 1 ? dirItem : fileItem)
    }


    // display dir up
    Component {
        id: upItem
        Item {
            width: parent.width
            height: main.sizeListItem
            Image {
                id: backImage
                anchors.left: parent.left
                anchors.margins: main.sizeMargins
                anchors.rightMargin: 2 * main.sizeMargins
                anchors.verticalCenter: parent.verticalCenter
                source: "/images/navigation_previous_item.png"
            }

            // title text (dir name on subdirs)
            Text {
                color: "white"
                font.pixelSize: main.sizeFontHead
                anchors.margins: main.sizeMargins
                anchors.right: parent.right
                anchors.top: parent.top
                text: title
                width: parent.width - backImage.width - 2 * main.sizeMargins
                elide: Text.ElideRight
            }

            // artist text
            Text {
                color: "white"
                font.pixelSize: main.sizeFontListItem
                anchors.margins: main.sizeMargins
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: artist
                width: parent.width - backImage.width - 2 * main.sizeMargins
                elide: Text.ElideLeft
            }

            MouseArea {
                anchors.fill: parent
                onClicked: browsescrollview.send_browse(file)
            } // mouse area
        } // item
    } // up Component


    Component {
        id: dirItem
        Item {
            width: parent.width
            height: main.sizeListItem

            Image {
                id: nextImage
                anchors.right: parent.right
                anchors.margins: main.sizeMargins
                anchors.rightMargin: 2 * main.sizeMargins
                anchors.leftMargin: 2 * main.sizeMargins
                anchors.verticalCenter: parent.verticalCenter
                source: "/images/navigation_next_item.png"
            }

            Rectangle {
                id: nextRect
                anchors.right: parent.right
                height: parent.height
                width: nextImage.width + 2 * main.sizeMargins
                color: "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: browsescrollview.send_browse(file)
                }
            }

            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: parent.width - nextRect.width
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var elem = browseview.model.get(index);
                        elem.selected = ! selected;
                    }
                    onDoubleClicked: browsescrollview.send_browse(file)
                } // mouse area
            }

            // title text (dir name on subdirs)
            Text {
                color: "white"
                font.pixelSize: main.sizeFontHead
                anchors.margins: main.sizeMargins
                anchors.left: parent.left
                anchors.top: parent.top
                text: title
                width: parent.width - nextRect.width - main.sizeMargins
                elide: Text.ElideRight
            }

        } // item
    } // dir Component



    // display directory item
    Component {
        id: fileItem
        Item {
            width: parent.width
            height: main.sizeListItem

            // title text (dir name on subdirs)
            Text {
                color: "white"
                font.pixelSize: main.sizeFontListItem
                anchors.margins: main.sizeMargins
                anchors.left: parent.left
                anchors.top: parent.top
                text: title
                width: parent.width - 4*main.sizeFontListItem-4*main.sizeMargins
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

            Rectangle {
                anchors.fill: parent
                color: "#11ffff99"
                visible: mouse.pressed
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: {
                    if (ftype !== 0) {
                        var elem = browseview.model.get(index);
                        elem.selected = ! selected;
                    }
                }
                onPressAndHold: {
                    var elem = browseview.model.get(index);
                    elem.selected = false;
                    browseview.model.append_item(file, title);
                }
            } // mouse area
        } // item
    } // file component

}
