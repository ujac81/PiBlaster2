

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

Item {
    width: parent.width
    height: parent.height

    property real progress: 0
    SequentialAnimation on progress {
        loops: Animation.Infinite
        running: true
        NumberAnimation {
            from: 0
            to: 1
            duration: 3000
        }
        NumberAnimation {
            from: 1
            to: 0
            duration: 3000
        }
    }

    Column {
        spacing: main.sizeVerticalSpacing
        anchors.centerIn: parent

        Button {
            id: connectButton
            enabled: ! main.btconnected && ! main.btconnecting
            visible: ! main.btconnected && ! main.btconnecting
            text: "Connect"
            style: touchStyle
            onClicked: {
                UI.bt_reconnect()
            }
        }

        Button {
            id: disconnectButton
            enabled: main.btconnected || main.btconnecting
            visible: main.btconnected || main.btconnecting
            text: "Disconnect"
            style: touchStyle
            onClicked: {
                UI.bt_disconnect()
            }
        }
    }

    Component {
        id: touchStyle
        ButtonStyle {
            panel: Item {
                implicitHeight: main.sizeButton
                implicitWidth: main.sizeButtonWidth
                BorderImage {
                    anchors.fill: parent
                    antialiasing: true
                    border.bottom: main.sizeLine
                    border.top: main.sizeLine
                    border.left: main.sizeLine
                    border.right: main.sizeLine
                    anchors.margins: control.pressed ? -main.sizeLine/2 : 0
                    source: control.pressed ? "/images/button_pressed.png" : "/images/button_default.png"
                    Text {
                        text: control.text
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: main.sizeFontButton
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
