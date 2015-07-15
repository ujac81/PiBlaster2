import QtQuick 2.0


import "../UI.js" as UI


ListModel {
    id: uploadModel

    property string cur_parent: "/"


    /**
     * Called by main if dirlisting message received from PI
     */
    function received_upload(msg) {

        if ( msg.status() === 0 ) {
            clear();

            var app = {}
            var parentdir = msg.message();
            uploadModel.cur_parent = parentdir;

            console.log("New Listing -- Parent Dir = --"+parentdir+"--");

            if (parentdir !== "") {
                app = {
                    "ftype": 0,
                    "title": "..",
                    "artist": parentdir,
                    "selected": false,
                    "file": parentdir
                }
                append(app);
            }


            for ( var i = 0; i < msg.payloadSize(); i++ ) {
                var arr = msg.payloadElements(i);
                app = {
                        "ftype": parseInt(arr[0]),
                        "title": arr[1],
                        "artist": "", // parentdir for '..'
                        "file": arr[2],
                        "selected": false
                       };
                append(app);
            }
        } else {
            UI.setStatus("Bad return status for 'dirlisting'");
        }
    }

    function deselect_all() {
        for ( var i = 0; i < count; i++ ) {
            get(i).selected = false;
        }
    }

    function select_all() {
        for ( var i = 0; i < count; i++ ) {
            get(i).selected = true;
        }
    }

    function invert_selection() {
        for ( var i = 0; i < count; i++ ) {
            get(i).selected = ! get(i).selected;
        }
    }

    function process_selection(cmd) {
        btService.clearSendPayload();
        for ( var i = 0; i < count; i++ ) {
            if (get(i).selected) {
                btService.addToSendPayload(get(i).file);
            }
        }
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload(cmd);
            keepalive.running = true;
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }
        deselect_all();
    }
}

