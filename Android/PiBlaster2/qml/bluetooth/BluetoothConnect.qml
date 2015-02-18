
import QtQuick 2.2
import QtBluetooth 5.3

Item {

    property string remoteDeviceName: ""
    property bool serviceFound: false


    BluetoothDiscoveryModel {
        id: btModel
        running: false
        discoveryMode: BluetoothDiscoveryModel.MinimalServiceDiscovery
        remoteAddress: "00:1A:7D:DA:71:14"
        uuidFilter: "94f39d29-7d6d-437d-973b-fba39e49d4ee"

        onRunningChanged : {
            if (! btModel.running && ! serviceFound) {
                // TODO: pop up message
                console.log("\nNo service found. \n\nPlease start server\nand restart app.\n");
            }
            if ( ! btModel.running ) {
                console.log("BluetoothDiscoveryModel: running = false.");
                serviceFound = false;
            }
            if ( btModel.running ) {
                console.log("BluetoothDiscoveryModel: running = true.");
            }
        }

        onErrorChanged: {
            switch (btModel.error) {
                case BluetoothDiscoveryModel.PoweredOffError:
                    console.log("Error: Bluetooth device not turned on");
                    break;
                case BluetoothDiscoveryModel.InputOutputError:
                    console.log("Error: Bluetooth I/O Error");
                    break;
                case BluetoothDiscoveryModel.InvalidBluetoothAdapterError:
                    console.log("Error: Invalid Bluetooth Adapter Error");
                    break;
                case BluetoothDiscoveryModel.NoError:
                    break;
                default:
                    console.log("Error: Unknown Error"); break;
            }
        }

        onServiceDiscovered: {
            if (serviceFound)
                return
            serviceFound = true
            console.log("=== BT Service Discovered ===");
            console.log("address: " + service.deviceAddress);
            console.log("name: " + service.deviceName);
            console.log("service: " + service.serviceName);
            console.log("registered: " + service.registered);
            console.log("desc: " + service.serviceDescription);
            console.log("proto: " + service.serviceProtocol);
            console.log("uuid: " + service. serviceUuid);
            remoteDeviceName = service.deviceName
            main.bt_setService(service)
        }
    }


    function reconnect() {
        console.log("Reconnecting BT...");
        disconnect();
        btModel.running = true;
    }

    function disconnect() {
        console.log("Disconnecting...");
        serviceFound = false;
        btModel.running = false;
    }

}
