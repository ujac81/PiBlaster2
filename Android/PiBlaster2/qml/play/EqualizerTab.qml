

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../items"

Rectangle {
    id: equalTab

    width: parent.width
    height: parent.height
    color: "transparent"

    property variant equalText: []
    property variant equalVal: []

    Flickable {
        id: equalFlick
        anchors.fill: parent

        contentWidth: equalRow.width
        contentHeight: equalRow.height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalAndVerticalFlick
        leftMargin: 0.1 * equalTab.width
        topMargin: 0.1 * equalTab.width
        bottomMargin: 0.1 * equalTab.width
        rightMargin: 0.1 * equalTab.width

        Row {
            id: equalRow
            spacing: 20
            height: 0.8 * equalTab.width


            Repeater {

                model: equalTab.equalText.length

                Column {
                    spacing: 20
                    width: 50

                    Slider {
                        height: 0.8 * equalTab.height - 20 - 20 - 10
                        width: 50
                        style: touchStyle
                        value: equalTab.equalVal[index]
                        updateValueWhileDragging: false
                        minimumValue: 0
                        maximumValue: 100
                        orientation: Qt.Vertical
                        stepSize: 1
                        onValueChanged: {
//                            if (volPlayVolumeSider.value !== volTab.playVolume) {
//                                main.btSendSingle("setvolume "+volPlayVolumeSider.value);
//                                volTab.playVolume = volPlayVolumeSider.value;
//                            }
                            console.log("EQUAL "+index+"="+value);
                        }
                    }


                    Text {
                        width: 50
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignBottom
                        font.pixelSize: 20
                        text: equalTab.equalText[index]
                        color: "white"
                    }
                }
            }


            // Only show the scrollbars when the view is moving.
            states: State {
                name: "ShowBar"
                when: equalFlick.movingVertically || equalFlick.movingHorizontally
                PropertyChanges { target: equalVertScrollBar; opacity: 1 }
                PropertyChanges { target: equalHorizScrollBar; opacity: 1 }
            }

            transitions: Transition {
                NumberAnimation { properties: "opacity"; duration: 400 }
            }

        } // row
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
        id: equalVertScrollBar
        width: 12; height: equalFlick.height-12
        anchors.right: equalFlick.right
        opacity: 0
        orientation: Qt.Vertical
        position: equalFlick.visibleArea.yPosition
        pageSize: equalFlick.visibleArea.heightRatio
    }
    ScrollBar {
        id: equalHorizScrollBar
        width: equalFlick.width-12; height: 12
        anchors.bottom: equalFlick.bottom
        opacity: 0
        orientation: Qt.Horizontal
        position: equalFlick.visibleArea.xPosition
        pageSize: equalFlick.visibleArea.widthRatio
    }


    function update_status(msg) {
        if (msg.payloadSize() !== 2) {
            main.setStatus("Ill-formed payload received for equal-status!")
        } else {

            var arr = msg.payloadElements(0);
            equalVal.length = 0;
            for (var i = 0; i < arr.length; i++ ) {
                equalVal.push(parseInt(arr[i]));
            }
            equalText = msg.payloadElements(1);
        }
    }
}
