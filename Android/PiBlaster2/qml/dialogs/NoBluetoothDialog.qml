
import QtQuick 2.2
import QtQuick.Dialogs 1.1

Item {

    MessageDialog {
        id: msgdiagNoBluetooth
        visible: false
        modality: Qt.WindowModal
        title: "Bluetooth disabled."
        text: "Bluetooth has been disabled."
        informativeText: "Please restart app and keep bluetooth enabled while using it!"
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Close

        onButtonClicked: {
            console.log("Leaving from NoBluetoothDialog...");
            Qt.quit();
        }
    }


    function open() {
        msgdiagNoBluetooth.open();
    }


    function service_error(error) {
        msgdiagNoBluetooth.title = "Bluetooth Error";
        msgdiagNoBluetooth.text = "Bluetooth service failed!";
        msgdiagNoBluetooth.informativeText = error;
        msgdiagNoBluetooth.open();
    }
}
