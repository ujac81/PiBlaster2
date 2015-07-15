
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI

ScrollView {

    id: uploadscrollview

    objectName: "UploadPage"

    width: parent.width
    height: parent.height

    flickableItem.interactive: true
    focus: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Back && uploadview.model.cur_parent !== "/") {
            uploadscrollview.send_browse(uploadview.model.cur_parent);
            event.accepted = true;
        }
        if (event.key === Qt.Key_Menu) {
            main.popupMenu("upload");
            event.accepted = true;
        }
    }



    ListView {
        id: uploadview
        anchors.fill: parent
        model: UploadModel {}
        delegate: UploadDelegate {}
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
        console.log("UPLOAD ACTIVATED");
        send_browse("/");
    }


    function send_browse(dir) {
        btService.clearSendPayload();
        btService.addToSendPayload("-"+dir+"-");
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload("browseusb");
            keepalive.running = true;
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }
    }


    function update_upload(msg) {
        console.log("update_browse");
        uploadview.model.received_upload(msg);
    }


    function upload_action(action_name) {
        if (action_name === "scroll_start") {
            uploadview.positionViewAtBeginning()
        }
        else if (action_name === "scroll_end") {
            uploadview.positionViewAtEnd()
        }
        else if (action_name === "select_all") {
            uploadview.model.select_all();
        }
        else if (action_name === "deselect_all") {
            uploadview.model.deselect_all();
        }
        else if (action_name === "invert_selection") {
            uploadview.model.invert_selection();
        }
        else if (action_name === "upload") {
            uploadview.model.process_selection("upload");
        }
        else {
            console.log("ERROR: illegal action_name "+action_name);
        }
    }
}
