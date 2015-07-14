
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

ScrollView {

    id: browsescrollview

    objectName: "BrowsePage"

    width: parent.width
    height: parent.height

    flickableItem.interactive: true

    ListView {
        id: browseview
        anchors.fill: parent
        model: BrowseModel {}
        delegate: BrowseDelegate {}
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
        console.log("BROWSE ACTIVATED");
        send_browse("local");
    }


    function send_browse(dir) {
        btService.clearSendPayload();
        btService.addToSendPayload("-"+dir+"-");
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload("browse");
            keepalive.running = true;
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }
    }


    function update_browse(msg) {
        console.log("update_browse");
        browseview.model.received_browse(msg);
    }


    function browse_action(action_name) {
        if (action_name === "scroll_start") {
            browseview.positionViewAtBeginning()
        }
        else if (action_name === "scroll_end") {
            browseview.positionViewAtEnd()
        }
        else if (action_name === "select_all") {
            browseview.model.select_all();
        }
        else if (action_name === "deselect_all") {
            browseview.model.deselect_all();
        }
        else if (action_name === "invert_selection") {
            browseview.model.invert_selection();
        }
        else if (action_name === "selection_after_current") {
            browseview.model.process_selection("pladdselaftercur");
        }
        else if (action_name === "selection_to_end") {
            browseview.model.process_selection("pladdseltoend");
        }
        else {
            console.log("ERROR: illegal action_name "+action_name);
        }

    }
}
