 
import QtQuick 2.2
import QtQuick.Controls.Styles 1.1


TabViewStyle {
    tabsAlignment: Qt.AlignVCenter
    tabOverlap: 0
    frame: Item {}
    tab: Item {
        implicitWidth: control.width/control.count
        implicitHeight: main.sizeTabBar
        BorderImage {
            anchors.fill: parent
            border.bottom: main.sizeLine
            border.top: main.sizeLine
            source: styleData.selected ? "/images/tab_selected.png":"/images/tabs_standard.png"
            Text {
                anchors.centerIn: parent
                color: "white"
                text: styleData.title.toUpperCase()
                font.pixelSize: main.sizeFontTabHead
            }
            Rectangle {
                visible: index > 0
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: main.sizeLine
                width:1
                color: "#3a3a3a"
            }
        }
    }
}
