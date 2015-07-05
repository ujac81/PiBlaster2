
import QtQuick 2.4
import QtQuick.Controls.Styles 1.1


SliderStyle {
    handle: Rectangle {
        width: main.sizeSlideButton
        height: main.sizeSlideButton
        radius: height
        antialiasing: true
        color: Qt.lighter("#468bb7", 1.2)
    }

    groove: Item {
        implicitHeight: main.sizeSlideButton + 2 * main.sizeMargins
        implicitWidth: main.sizeSlider
        Rectangle {
            height: main.sizeMargins
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
