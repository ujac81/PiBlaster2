import QtQuick 2.0


import "../UI.js" as UI


ListModel {
    id: playlistModel

    function clearAll() {
        console.log("PlayListModel: clearAll()");
        clear();
    }


    /**
     * Called by main if shwowdevices message received from PI
     */
    function received_playlist(msg) {
        clearAll();

        var nowIndex = -1
        if ( msg.status() === 0 ) {
            nowIndex = parseInt(msg.message());
            for ( var i = 0; i < msg.payloadSize(); i++ ) {
                var arr = msg.payloadElements(i);
                var app = {
                        "index": i,
                        "position": arr[0],
                        "title": arr[1],
                        "artist": arr[2],
                        "album": arr[3],
                        "length": arr[4],
                        "id": arr[5],
                        "selected": false,
                        "active": ( parseInt(arr[0]) === nowIndex )
                       };
                append(app);
            }
        } else {
            root.log_error("Bad return status for 'playlistinfocurrent'");
        }

        if ( nowIndex != -1 ) {
            playlistview.positionViewAtIndex(nowIndex, ListView.Center)
        }
    }


    function update_playlistposition(msg) {
        var arr = msg.payloadElements(0);
        var pos = arr[13];
        console.log("Activate elem #"+pos);
        for ( var i = 0; i < count; i++ ) {
            get(i).active = get(i).position === pos;
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

    // play 1st selected item now.
    function play_now() {
        for ( var i = 0; i < count; i++ ) {
            if (get(i).selected) {
                UI.btSendSingle("playpos "+get(i).position);
                deselect_all();
                return;
            }
        }
    }


    // scroll to currently active tune.
    function scroll_now() {
        for ( var i = 0; i < count; i++ ) {
            if (get(i).active) {
                playlistview.positionViewAtIndex(i, ListView.Center)
                return;
            }
        }
    }


    function process_selection(cmd) {
        btService.clearSendPayload();
        for ( var i = 0; i < count; i++ ) {
            if (get(i).selected) {
                btService.addToSendPayload(get(i).id);
            }
        }
        if (main.btconnected) {
            keepalive.running = false;
            btService.writeSocketWithPayload(cmd);
            keepalive.running = true;
        } else {
            UI.setStatus("Not connected to PiBlaster!");
        }

    }

    function playlist_move(id, moveTo) {
        playlistview.model.move(id, moveTo, 1);
        UI.btSendSingle("plmove "+id+" "+moveTo);
    }



}

