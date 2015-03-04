

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

Item {
    objectName: "PlayPage"

    width: parent.width
    height: parent.height

    TabView {
        id: playTabView
        anchors.fill: parent
        style: touchStyle
        Tab {
            title: "Play"
            PlayTab{ visible: true }
        }
        Tab {
            title: "Volume"
            VolumeTab{ visible: true }
        }
        Tab {
            title: "Equalizer"
            EqualizerTab{ visible: true }
        }

        onCurrentIndexChanged: tabChanged(currentIndex);

        function tabChanged(index) {
            if ( index ===  0 ) {
                main.btSendSingle("playstatus");
            }
            if ( index ===  1 ) {
                main.btSendSingle("volstatus");
            }
            if ( index ===  2 ) {
                main.btSendSingle("equalstatus");
            }
        }
    }

    Component {
        id: touchStyle
        TabViewStyle {
            tabsAlignment: Qt.AlignVCenter
            tabOverlap: 0
            frame: Item {}
            tab: Item {
                implicitWidth: control.width/control.count
                implicitHeight: 50
                BorderImage {
                    anchors.fill: parent
                    border.bottom: 8
                    border.top: 8
                    source: styleData.selected ? "/images/tab_selected.png":"/images/tabs_standard.png"
                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        text: styleData.title.toUpperCase()
                        font.pixelSize: 16
                    }
                    Rectangle {
                        visible: index > 0
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        width:1
                        color: "#3a3a3a"
                    }
                }
            }
        }
    }

    function activated() {
        playTabView.tabChanged(0);
    }


    function update_status(msg) {
        if (msg.code() === 304) {
            playTabView.getTab(0).item.update_status(msg);
        }
        if (msg.code() === 404) {
            playTabView.getTab(1).item.update_status(msg);
        }
        if (msg.code() === 504) {
            playTabView.getTab(2).item.update_status(msg);
        }
    }
}
