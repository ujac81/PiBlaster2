

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../component"

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

        onCurrentIndexChanged: tabChanged(currentIndex)

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
        TabStyle {}
    }


    function activated() {
        connectTabView.tabChanged(0);
    }
}
