

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../items"
import "../UI.js" as UI

import "../component"

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
            spacing: 2*main.sizeMargins
            height: 0.8 * equalTab.width


            Repeater {
                id: equalRepeater

                model: equalTab.equalText.length

                Column {
                    spacing: 2*main.sizeMargins
                    width: main.sizeSlideButton+2*main.sizeMargins

                    Slider {
                        id: equalSlide
                        height: 0.8 * equalTab.height - 5*main.sizeMargins
                        width: main.sizeSlideButton+2*main.sizeMargins
                        style: touchStyle
                        value: equalTab.equalVal[index]
                        updateValueWhileDragging: false
                        minimumValue: 0
                        maximumValue: 100
                        orientation: Qt.Vertical
                        stepSize: 1
                        onValueChanged: {
                            if (value !== equalTab.equalVal[index]) {
                                UI.btSendSingle("setequal "+index+" "+value);
                                equalTab.equalVal[index] = value
                            }
                        }
                    }


                    Text {
                        id: equalText
                        width: main.sizeSlideButton+2*main.sizeMargins
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignBottom
                        font.pixelSize: main.sizeFontItem
                        text: equalTab.equalText[index]
                        color: "white"
                    }
                    function set_equal_val() {
                        equalSlide.value = equalTab.equalVal[index];
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

        function update_vals() {
            for(var i = 0; i < equalRepeater.count; i++) {
                equalRepeater.itemAt(i).set_equal_val()
            }
        }

    } // flick

    Component {
        id: touchStyle
        SlideStyle {}
    }

    // Attach scrollbars to the right and bottom edges of the view.
    ScrollBar {
        id: equalVertScrollBar
        width: main.sizeScrollBar
        height: equalFlick.height-main.sizeScrollBar
        anchors.right: equalFlick.right
        opacity: 0
        orientation: Qt.Vertical
        position: equalFlick.visibleArea.yPosition
        pageSize: equalFlick.visibleArea.heightRatio
    }
    ScrollBar {
        id: equalHorizScrollBar
        width: equalFlick.width-main.sizeScrollBar
        height: main.sizeScrollBar
        anchors.bottom: equalFlick.bottom
        opacity: 0
        orientation: Qt.Horizontal
        position: equalFlick.visibleArea.xPosition
        pageSize: equalFlick.visibleArea.widthRatio
    }


    function update_status(msg) {
        if (msg.payloadSize() !== 2) {
            UI.setStatus("Ill-formed payload received for equal-status!")
        } else {

            console.log("SET EQUAL STATUS");
            console.log(msg.payloadElements(0));
            console.log(msg.payloadElements(1));

            var arr = msg.payloadElements(0);
            equalVal.length = 0;
            for (var i = 0; i < arr.length; i++ ) {
                equalVal.push(parseInt(arr[i]));
            }
            equalText = msg.payloadElements(1);

            equalFlick.update_vals();
        }
    }
}
