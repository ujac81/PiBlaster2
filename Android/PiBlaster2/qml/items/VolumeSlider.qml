
import QtQuick 2.4
import QtQuick.Controls 1.2

// TODO replace sliders in volume page


Column {
    spacing: main.sizeMargins
    width: parent.width
    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignBottom
        font.pixelSize: main.sizeFontItem
        text: "Master Volume " + volTab.playVolume
        color: "white"
    }
    Slider {
        id: volPlayVolumeSider
        width: parent.width
        anchors.margins: 2*main.sizeMargins
        style: touchStyle
        value: volTab.playVolume
        updateValueWhileDragging: false
        minimumValue: 0
        maximumValue: 100
        stepSize: 1
        onValueChanged: {
            if (volPlayVolumeSider.value !== volTab.playVolume) {
                UI.btSendSingle("setvolume "+volPlayVolumeSider.value);
                volTab.playVolume = volPlayVolumeSider.value;
            }
        }
    }
}
