
import QtQuick 2.2


Item
{


    function processMessage(msg) {
        console.log("Got message: id="+msg.id()+", status="+msg.status()+
                    ", code="+msg.code()+", payload_size="+msg.payloadSize()+
                    ", msg="+msg.message());

        if (msg.code() === 2) {
            main.bt_error("Wrong password!");
        }
        if (msg.status() === 2 ) {
            main.setStatus("Command not supported by PiBlaster!");
        }

    }






}
