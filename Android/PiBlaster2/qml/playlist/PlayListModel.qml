import QtQuick 2.0


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
                var app = {"position": arr[0],
                        "title": arr[1],
                        "artist": arr[2],
                        "album": arr[3],
                        "length": arr[4],
                        "selected": false,
                        "active": ( parseInt(arr[0]) === nowIndex )
                       };
//                console.log(msg.payloadElements(i));
//                console.log(arr[1]);
//                console.log(app.title);
                append(app);
            }
        } else {
            root.log_error("Bad return status for 'playlistinfocurrent'");
        }

        if ( nowIndex != -1 ) {
            playlistview.positionViewAtIndex(nowIndex, ListView.Center)
        }
    }





}

