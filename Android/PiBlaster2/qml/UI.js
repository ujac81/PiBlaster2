
////////////////////// BLUETOOTH ACTIONS //////////////////////


function bt_reconnect() {
    console.log("SCANNING...");
    btService.serviceSearch(main.btmac);
    main.btconnecting = true;
    main.btconnected = false;
}
function bt_disconnect() {
    console.log("DISCONNECTING...");
    btService.disconnectService();
    main.btconnecting = false;
    main.btconnected = false;
}


function bt_message(msg) {
    console.log("BT SERVICE MESSAGE: "+msg);
    setStatus("Bluetooth: "+msg);
}

// Raise no bluetooth dialog if bluetooth adapter lost.
// App will exit if button on dialog clicked.
// Connected to BTService::bluetoothModeChanged().
function bt_devstate(state) {
    console.log("BT DEVICE STATE: "+state);
    if (state === 0 && lastBTDeviceState === 1) {
        diagNoBluetooth.open();
    }
    if (lastBTDeviceState === 0 && state === 1 && main.btautoconnect) {
        console.log("Bluetooth activated -- autoconnecting...");
        bt_reconnect();
    }
    main.lastBTDeviceState = state;
}

// Set error message for failure dialog and raise dialog.
// App will exit after dialog.
function bt_error(error) {
    main.btautoconnect = false;
    diagNoBluetooth.service_error(error);
}

// Set warning message for failure dialog and raise dialog.
function bt_warning(warning) {
    diagNoBluetooth.service_warning(warning);
}

function bt_connected() {
    btService.writeSocket(main.btpin);
    main.btconnected = true;
    main.btconnecting = false;
    keepalive.running = true;
    main.btautoconnect = true;
}

function bt_disconnected() {
    console.log("Disconnected...");
    main.btconnected = false;
    main.btconnecting = false;
    keepalive.running = false;
}

function btSendSingle(cmd) {
    if (main.btconnected) {
        // reset keep alive to prevent interference with command sending.
        keepalive.running = false;
        btService.writeSocket(cmd);
        keepalive.running = true;
    } else {
        setStatus("Not connected to PiBlaster!");
    }
}

////////////////////// OTHER ACTIONS //////////////////////

function setStatus(msg) {
    main.statustext = msg;
    deletestatus.restart();
}
