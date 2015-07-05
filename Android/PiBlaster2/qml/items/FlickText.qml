
import QtQuick 2.2

Rectangle {

    property int textheight: main.sizeFontHead
    property string flicktext: "some text"
    property int textweight: Font.Normal


    color: "transparent"
    width: parent.width
    height: textheight * 1.5

    Flickable {
        anchors.fill: parent
        contentWidth: flickText.width
        contentHeight: flickText.height
        flickableDirection: Flickable.HorizontalFlick
        clip: true
        Text {
            anchors.centerIn: parent
            id: flickText
            font.pixelSize: textheight
            font.weight: textweight
            text: flicktext
            color: "white"
        }
    }
}
