
import QtQuick 2.2


Item
{


    function processMessage(msg) {
        if ( msg.code() !== 1000 ) {
            console.log("Got message: id="+msg.id()+", status="+msg.status()+
                        ", code="+msg.code()+", payload_size="+
                        msg.payloadSize()+", msg="+msg.message());
        }

        if (msg.code() === 2) {
            main.bt_error("Wrong password!");
        }
        if (msg.status() === 2 ) {
            main.setStatus("Command not supported by PiBlaster!");
        }

        if (msg.code() === 304) {
            // answer on playstatus
            stackView.update_status(msg)
        }

        if (msg.code() === 305 || msg.code() === 306) {
            main.playPlaying = false;
        }

        if (msg.code() === 307) {
            main.playPlaying = true;
        }

        if (msg.code() === 404) {
            // answer on volstatus
            stackView.update_status(msg)
        }
    }


}
