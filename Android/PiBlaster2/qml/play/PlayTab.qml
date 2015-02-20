

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../items"

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

        FlickText {
            textheight: 28
            flicktext: main.playSong
            textweight: Font.DemiBold
        }
        FlickText {
            textheight: 24
            flicktext: main.playArtist
        }
        FlickText {
            textheight: 20
            flicktext: main.playAlbum
        }

        Row {
            spacing: 20
            height: 48
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                source: "qrc:///images/play/backward.png"
                width: parent.height
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("playprev");
                }
            }
            Image {
                source: "qrc:///images/play/stop.png"
                width: parent.height
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("playstop");
                }
            }
            Image {
                source: main.playPlaying ? "qrc:///images/play/pause.png" : "qrc:///images/play/play.png"
                width: parent.height
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("playtoggle");
                }
            }
            Image {
                source: "qrc:///images/play/forward.png"
                width: parent.height
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("playnext");
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 60
            height: 48

            Image {
                source: "qrc:///images/play/shuffle.png"
                width: parent.height
                height: parent.height
                opacity: main.playShuffle ? 1 : 0.5
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("toggleshuffle");
                }
            }
            Image {
                source: "qrc:///images/play/repeat.png"
                width: parent.height
                height: parent.height
                opacity: main.playRepeat ? 1 : 0.5
                MouseArea {
                    anchors.fill: parent
                    onClicked: main.btSendSingle("togglerepeat");
                }
            }
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
                text: "Volume " + main.playVolume
                color: "white"
            }
            Slider {
                id: playPlayVolumeSider
                anchors.margins: 20
                style: touchStyle
                value: main.playVolume
                updateValueWhileDragging: false
                minimumValue: 0
                maximumValue: 100
                stepSize: 1
                onValueChanged: {
                    main.btSendSingle("setvolume "+playPlayVolumeSider.value);
                }
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
