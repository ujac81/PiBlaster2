

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../items"
import "../UI.js" as UI

Rectangle {
    id: playTab

    width: parent.width
    height: parent.height
    color: "transparent"

    property string playSong: "No Song Name"
    property string playArtist: "No Artist"
    property string playAlbum: "No Album"
    property int receivedStatus: 0
    property int playLength: 0
    property int playPosition: 0
    property string playPositionText: "0:00"
    property string playLengthText: "0:00"
    property int playVolume: 50
    property int playMixerVolume: 50
    property int playAmpVolume: 50


    Flickable {
        id: playFlick
        anchors.fill: parent

        contentWidth: playGrid.width
        contentHeight: playGrid.height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        leftMargin: 0.1 * playTab.width
        topMargin: 0.1 * playTab.width

        Column {
            id: playGrid
            spacing: 40
            width: 0.8 * playTab.width

            FlickText {
                textheight: 28
                flicktext: playTab.playSong
                textweight: Font.DemiBold
            }
            FlickText {
                textheight: 24
                flicktext: playTab.playArtist
            }
            FlickText {
                textheight: 20
                flicktext: playTab.playAlbum
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
                        onClicked: UI.btSendSingle("playprev");
                    }
                }
                Image {
                    source: "qrc:///images/play/stop.png"
                    width: parent.height
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.btSendSingle("playstop");
                    }
                }
                Image {
                    source: main.playPlaying ? "qrc:///images/play/pause.png" : "qrc:///images/play/play.png"
                    width: parent.height
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.btSendSingle("playtoggle");
                    }
                }
                Image {
                    source: "qrc:///images/play/forward.png"
                    width: parent.height
                    height: parent.height
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.btSendSingle("playnext");
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
                        onClicked: UI.btSendSingle("togglerandom");
                    }
                }
                Image {
                    source: "qrc:///images/play/repeat.png"
                    width: parent.height
                    height: parent.height
                    opacity: main.playRepeat ? 1 : 0.5
                    MouseArea {
                        anchors.fill: parent
                        onClicked: UI.btSendSingle("togglerepeat");
                    }
                }
            }

            Column {
                spacing: 10
                width: parent.width
                Text {
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 20
                    text: "Position " + playTab.playPositionText + " / " + playTab.playLengthText
                    color: "white"
                }
                Slider {
                    id: playPlayPosSider
                    property int preventSend: 1
                    width: parent.width
                    anchors.margins: 20
                    style: touchStyle
                    value: 0
                    updateValueWhileDragging: false
                    minimumValue: 0
                    stepSize: 1
                    onValueChanged: {
                        if (playPlayPosSider.value !== playTab.playPosition &&
                            playPlayPosSider.preventSend !== 1) {
                            console.log("POS SLIDER: val = "+playPlayPosSider.value+", pos = "+playTab.playPosition);
                            UI.btSendSingle("setpos "+playPlayPosSider.value);
                        }
                    }
                }
            }
            Column {
                spacing: 10
                width: parent.width
                Text {
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 20
                    text: "Volume " + playTab.playVolume
                    color: "white"
                }
                Slider {
                    id: playPlayVolumeSider
                    width: parent.width
                    anchors.margins: 20
                    style: touchStyle
                    value: playTab.playVolume
                    updateValueWhileDragging: false
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                    onValueChanged: {
                        if (playPlayVolumeSider.value !== playTab.playVolume) {
                            UI.btSendSingle("setvolume "+playPlayVolumeSider.value);
                            playTab.playVolume = playPlayVolumeSider.value;
                        }
                    }
                }
            }
        } // column

        // Only show the scrollbars when the view is moving.
        states: State {
            name: "ShowBar"
            when: playFlick.movingVertically
            PropertyChanges { target: playScrollBar; opacity: 1 }
        }

        transitions: Transition {
            NumberAnimation { properties: "opacity"; duration: 400 }
        }

    } // flick

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

    Timer {
        id: positionTimer
        interval: 1000
        running: main.playPlaying
        repeat: true
        onTriggered: {
            var pos = playTab.playPosition;
            pos += 1;
            if (pos > playLength) {
                pos = playLength;
            }
            playTab.playPosition = pos;
            playPlayPosSider.value = pos;
            playPositionText = seconds_to_string(pos);
        }
    }

    // try refetch of status every 250 ms until received
    Timer {
        id: fetchStatusTimer
        interval: 250
        running: true
        repeat: true
        onTriggered:  {
            if (playTab.receivedStatus === 0) {
                UI.btSendSingle("playstatus");
            }
        }
    }

    // Attach scrollbars to the right and bottom edges of the view.
    ScrollBar {
        id: playScrollBar
        width: 12; height: playFlick.height-12
        anchors.right: playFlick.right
        opacity: 0
        orientation: Qt.Vertical
        position: playFlick.visibleArea.yPosition
        pageSize: playFlick.visibleArea.heightRatio
    }

    function update_status(msg) {
        if (msg.payloadElementsSize(0) !== 13) {
            UI.setStatus("Ill-formed payload received for play-status!")
        } else {
            var arr = msg.payloadElements(0);
            main.playShuffle = arr[0] === "1";
            main.playRepeat = arr[1] === "1";
            main.playPlaying = arr[2] === "play";
            playTab.playVolume = parseInt(arr[3]);
            var pos = parseFloat(arr[4]);
            playTab.playLength = parseInt(arr[5]);
            playTab.playAlbum = arr[6];
            playTab.playArtist = arr[7];
            playTab.playSong = arr[8];
            playTab.playPositionText = seconds_to_string(pos);
            playTab.playLengthText = seconds_to_string(playTab.playLength);

            playPlayVolumeSider.value = playTab.playVolume;

            playPlayPosSider.preventSend = 1;
            playPlayPosSider.maximumValue = playTab.playLength;
            playPlayPosSider.value = pos;
            playTab.playPosition = pos;
            playPlayPosSider.preventSend = 0;

            playTab.receivedStatus = 1;
        }
    }

    function seconds_to_string(time) {
        var res = "" + Math.floor(time/60) + ":";
        var sec = Math.floor(time % 60);
        if (sec < 10) { res += "0"; }
        res += sec;
        return res;
    }

}

