
import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.1

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

        Column {
            spacing: main.sizeVerticalSubSpacing
            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                font.pixelSize: main.sizeFontButton
                text: "PiBlaster MAC"
                color: "white"
            }
            TextField {
                focus: false
                id: macTextField
                anchors.margins: main.sizeMargins
                text: main.btmac
                style: touchStyle
                onAccepted: main.btmac = macTextField.text
            }
        }

        Column {
            spacing: main.sizeVerticalSubSpacing
            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                font.pixelSize: main.sizeFontButton
                text: "Connect Password"
                color: "white"
            }
            TextField {
                focus: false
                id: pwTextField
                anchors.margins: main.sizeMargins
                text: main.btpin
                style: touchStyle
                onAccepted: main.btpin = pwTextField.text
            }
        }

        Row {
            spacing: main.sizeVerticalSubSpacing

            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: main.sizeFontButton
                text: "Autoconnect"
                color: "white"
            }
            Switch {
                id: autoconnectSwitch
                style: switchStyle
                checked: main.btautoconnect
                onClicked: main.btautoconnect = autoconnectSwitch.checked
            }
        }

    }
    Component {
        id: touchStyle

        TextFieldStyle {
            textColor: "white"
            font.pixelSize: main.sizeFontButton
            background: Item {
                implicitHeight: main.sizeButton
                implicitWidth: main.sizeButtonWidth
                BorderImage {
                    source: "/images/textinput.png"
                    border.left: main.sizeLine
                    border.right: main.sizeLine
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }
    }

    Component {
        id: switchStyle
        SwitchStyle {

            groove: Rectangle {
                implicitHeight: main.sizeButton
                implicitWidth: main.sizeButtonWidth / 2
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.width/2 - 2
                    height: main.sizeVerticalSubSpacing
                    anchors.margins: 2
                    color: control.checked ? "#468bb7" : "#222"
                    Behavior on color {ColorAnimation {}}
                    Text {
                        font.pixelSize: main.sizeFontButton
                        color: "white"
                        anchors.centerIn: parent
                        text: "ON"
                    }
                }
                Item {
                    width: parent.width/2
                    height: parent.height
                    anchors.right: parent.right
                    Text {
                        font.pixelSize: main.sizeFontButton
                        color: "white"
                        anchors.centerIn: parent
                        text: "OFF"
                    }
                }
                color: "#222"
                border.color: "#444"
                border.width: 2
            }
            handle: Rectangle {
                width: parent.parent.width/2
                height: control.height
                color: "#444"
                border.color: "#555"
                border.width: 2
            }
        }
    }
}
