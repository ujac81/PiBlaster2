

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

ScrollView {


    width: parent.width
    height: parent.height

    flickableItem.interactive: true

    ListView {
        id: searchview
        anchors.fill: parent
        model: SearchModel {}
        delegate: SearchDelegate {}
    }

    style: ScrollViewStyle {
        transientScrollBars: true
        handle: Item {
            implicitWidth: 14
            implicitHeight: 26
            Rectangle {
                color: "#424246"
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.bottomMargin: 6
            }
        }
        scrollBarBackground: Item {
            implicitWidth: 14
            implicitHeight: 26
        }
    }


    function activated() {
        console.log("SEARCH ACTIVATED");
    }


    function send_search(search) {
        btService.clearSendPayload();
        btService.addToSendPayload("-"+search+"-");
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload("search");
            keepalive.running = true;
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }
    }


    function update_search(msg) {
        console.log("update_search");
        searchview.model.received_search(msg);
    }


    function search_action(action_name) {
        if (action_name === "select_all") {
            searchview.model.select_all();
        }
        else if (action_name === "deselect_all") {
            searchview.model.deselect_all();
        }
        else if (action_name === "invert_selection") {
            searchview.model.invert_selection();
        }
        else if (action_name === "selection_after_current") {
            searchview.model.process_selection("pladdselaftercur");
        }
        else if (action_name === "selection_to_end") {
            searchview.model.process_selection("pladdseltoend");
        }
        else {
            console.log("ERROR: illegal action_name "+action_name);
        }

    }
}
