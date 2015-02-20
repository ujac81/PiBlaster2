
import QtQuick 2.2
import QtQuick.Dialogs 1.1

Item {

    MessageDialog {
        id: msgdiagNoBluetooth

        property bool forceClose: false
        visible: false
        modality: Qt.WindowModal
        title: "Bluetooth disabled."
        text: "Bluetooth has been disabled."
        informativeText: "Please restart app and keep bluetooth enabled while using it!"
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Close

        onButtonClicked: {
            if (msgdiagNoBluetooth.forceClose) {
                console.log("Leaving from NoBluetoothDialog...");
                Qt.quit();
            } else {
                close();
            }
        }
    }


    function open() {
        msgdiagNoBluetooth.forceClose = true;
        msgdiagNoBluetooth.open();
    }


    function service_error(error) {
        msgdiagNoBluetooth.forceClose = true;
        msgdiagNoBluetooth.title = "Bluetooth Error";
        msgdiagNoBluetooth.text = "Bluetooth service failed!";
        msgdiagNoBluetooth.informativeText = error;
        msgdiagNoBluetooth.open();
    }

    function service_warning(warning) {
        msgdiagNoBluetooth.forceClose = false;
        msgdiagNoBluetooth.title = "Bluetooth Warning";
        msgdiagNoBluetooth.text = "Error in bluetooth service!";
        msgdiagNoBluetooth.informativeText = error;
        msgdiagNoBluetooth.open();
    }
}
