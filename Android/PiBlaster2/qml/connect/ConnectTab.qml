

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
        spacing: 40
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
                implicitHeight: 50
                implicitWidth: 320
                BorderImage {
                    anchors.fill: parent
                    antialiasing: true
                    border.bottom: 8
                    border.top: 8
                    border.left: 8
                    border.right: 8
                    anchors.margins: control.pressed ? -4 : 0
                    source: control.pressed ? "/images/button_pressed.png" : "/images/button_default.png"
                    Text {
                        text: control.text
                        anchors.centerIn: parent
                        color: "white"
                        font.pixelSize: 23
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
