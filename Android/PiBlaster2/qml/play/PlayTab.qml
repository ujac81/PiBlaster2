

import QtQuick 2.2
import QtQuick.Controls 1.2
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
        spacing: 40
        anchors.centerIn: parent

        Text {
            id: currentSong
            horizontalAlignment: Text.AlignCenter
            verticalAlignment: Text.AlignBottom
            font.pixelSize: 28
            font.weight: Font.DemiBold
            text: "SuperSongName"
            color: "white"
        }
        Text {
            id: currentArtist
            horizontalAlignment: Text.AlignCenter
            verticalAlignment: Text.AlignBottom
            font.pixelSize: 24
            text: "SuperArtist"
            color: "white"
        }
        Text {
            id: currentAlbum
            horizontalAlignment: Text.AlignCenter
            verticalAlignment: Text.AlignBottom
            font.pixelSize: 20
            text: "SuperAlbum"
            color: "white"
        }

        Row {
            spacing: 20
            Label { text: "prev" }
            Label { text: "pause" }
            Label { text: "stop" }
            Label { text: "next" }
        }

        Column {
            spacing: 10
            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 20
                text: "Position"
                color: "white"
            }
            Slider {
                anchors.margins: 20
                style: touchStyle
                value: 0.5
            }
        }
        Column {
            spacing: 10
            Text {
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                font.pixelSize: 20
                text: "Volume"
                color: "white"
            }
            Slider {
                anchors.margins: 20
                style: touchStyle
                value: 0.5
            }
        }
    }

    Component {
        id: touchStyle
        SliderStyle {
            handle: Rectangle {
                width: 30
                height: 30
                radius: height
                antialiasing: true
                color: Qt.lighter("#468bb7", 1.2)
            }

            groove: Item {
                implicitHeight: 50
                implicitWidth: 400
                Rectangle {
                    height: 8
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#444"
                    opacity: 0.8
                    Rectangle {
                        antialiasing: true
                        radius: 1
                        color: "#468bb7"
                        height: parent.height
                        width: parent.width * control.value / control.maximumValue
                    }
                }
            }
        }
    }
}
