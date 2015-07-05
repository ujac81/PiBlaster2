

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI
import "../component"

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
                UI.btSendSingle("playstatus");
                mainMenuBar.set_menu("playstatusMenu")
            }
            if ( index ===  1 ) {
                UI.btSendSingle("volstatus");
                mainMenuBar.set_menu("volstatusMenu")
            }
            if ( index ===  2 ) {
                UI.btSendSingle("equalstatus");
                mainMenuBar.set_menu("equalstatusMenu")
            }
        }
    }

    Component {
        id: touchStyle
        TabStyle {}
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
