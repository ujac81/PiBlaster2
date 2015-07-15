import QtQuick 2.0


import "../UI.js" as UI


ListModel {
    id: searchModel


    /**
     * Called by main if dirlisting message received from PI
     */
    function received_search(msg) {

        if ( msg.status() === 0 ) {
            clear();

            var app = {}

            for ( var i = 0; i < msg.payloadSize(); i++ ) {
                var arr = msg.payloadElements(i);
                app = {
                        "title": arr[0],
                        "artist": arr[1],
                        "album": arr[2],
                        "length": arr[3],
                        "file": arr[4],
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

    function append_item(file, title) {
        btService.clearSendPayload();
        btService.addToSendPayload(file);
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload('pladdseltoend');
            keepalive.running = true;
            UI.setStatus(title + " appended to playlist");
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }
    }
}
