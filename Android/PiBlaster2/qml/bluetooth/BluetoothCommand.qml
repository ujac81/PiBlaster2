
import QtQuick 2.2


Item
{


    function processMessage(msg) {
        console.log("Got message: id="+msg.id()+", status="+msg.status()+
                    ", code="+msg.code()+", payload_size="+msg.payloadSize()+
                    ", msg="+msg.message());

    }






}
