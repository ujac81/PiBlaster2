

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

Item {
    objectName: "ConnectPage"

    width: parent.width
    height: parent.height

    TabView {
        id: connectTabView
        anchors.fill: parent
        style: touchStyle
        Tab {
            title: "Connect"
            ConnectTab{ visible: true }
        }
        Tab {
            title: "Settings"
            SettingsTab{ visible: true }
        }

        onCurrentIndexChanged: tabChanged(index)

        function tabChanged(index) {
            if ( index ===  0 ) {
                mainMenuBar.set_menu("connectMenu");
            }
            if ( index ===  1 ) {
                mainMenuBar.set_menu("connectSettingsMenu");
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
        connectTabView.tabChanged(0);
    }
}
