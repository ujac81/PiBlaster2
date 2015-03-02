

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../items"

Rectangle {
    id: volTab

    width: parent.width
    height: parent.height
    color: "transparent"

    property int playVolume: 50
    property int playMixerVolume: 50
    property int playAmpVolume: 50

    Flickable {
        id: volFlick
        anchors.fill: parent

        contentWidth: volCol.width
        contentHeight: volCol.height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        leftMargin: 0.1 * volTab.width
        topMargin: 0.3 * volTab.width

        Column {
            id: volCol
            spacing: 40
            width: 0.8 * volTab.width

            //// master slider ////

            Column {
                spacing: 10
                width: parent.width
                Text {
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 20
                    text: "Master Volume " + volTab.playVolume
                    color: "white"
                }
                Slider {
                    id: volPlayVolumeSider
                    width: parent.width
                    anchors.margins: 20
                    style: touchStyle
                    value: volTab.playVolume
                    updateValueWhileDragging: false
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                    onValueChanged: {
                        if (volPlayVolumeSider.value !== volTab.playVolume) {
                            main.btSendSingle("setvolume "+volPlayVolumeSider.value);
                            volTab.playVolume = volPlayVolumeSider.value;
                        }
                    }
                }
            }

            //// mixer slider ////

            Column {
                spacing: 10
                width: parent.width
                Text {
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 20
                    text: "Mixer Volume " + volTab.playMixerVolume
                    color: "white"
                }
                Slider {
                    id: volMixerVolumeSider
                    width: parent.width
                    anchors.margins: 20
                    style: touchStyle
                    value: volTab.playMixerVolume
                    updateValueWhileDragging: false
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                    onValueChanged: {
                        if (volMixerVolumeSider.value !== volTab.playMixerVolume) {
                            main.btSendSingle("setvolumemixer "+volMixerVolumeSider.value);
                            volTab.playMixerVolume = volMixerVolumeSider.value;
                        }
                    }
                }
            }

            //// amp slider ////

            Column {
                spacing: 10
                width: parent.width
                Text {
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 20
                    text: "Amp Volume " + volTab.playAmpVolume
                    color: "white"
                }
                Slider {
                    id: volAmpVolumeSider
                    width: parent.width
                    anchors.margins: 20
                    style: touchStyle
                    value: volTab.playAmpVolume
                    updateValueWhileDragging: false
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                    onValueChanged: {
                        if (volAmpVolumeSider.value !== volTab.playAmpVolume) {
                            main.btSendSingle("setvolumeamp "+volAmpVolumeSider.value);
                            volTab.playAmpVolume = volAmpVolumeSider.value;
                        }
                    }
                }
            }

            // Only show the scrollbars when the view is moving.
            states: State {
                name: "ShowBar"
                when: volFlick.movingVertically
                PropertyChanges { target: volScrollBar; opacity: 1 }
            }

            transitions: Transition {
                NumberAnimation { properties: "opacity"; duration: 400 }
            }

        } // col
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

    // Attach scrollbars to the right and bottom edges of the view.
    ScrollBar {
        id: volScrollBar
        width: 12; height: volFlick.height-12
        anchors.right: volFlick.right
        opacity: 0
        orientation: Qt.Vertical
        position: volFlick.visibleArea.yPosition
        pageSize: volFlick.visibleArea.heightRatio
    }


    function update_status(msg) {
        if (msg.payloadElementsSize(0) !== 3) {
            main.setStatus("Ill-formed payload received for vol-status!")
        } else {
            var arr = msg.payloadElements(0);
            playVolume = parseInt(arr[0]);
            playMixerVolume = parseInt(arr[1]);
            playAmpVolume = parseInt(arr[2]);

            volPlayVolumeSider.value = playVolume;
            volMixerVolumeSider.value = playMixerVolume;
            volAmpVolumeSider.value = playAmpVolume;
        }
    }
}
