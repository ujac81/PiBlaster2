
#include "BTService.h"


BTService::BTService(BTCommMessageHandler* msgHandler):
    QObject(),
    _msgHandler(msgHandler),
    _foundPiBlasterService(false),
    _control(0),
    _service(0)
{
    _localDevice = new QBluetoothLocalDevice(this);

    connect(_localDevice,
            SIGNAL(hostModeStateChanged(QBluetoothLocalDevice::HostMode)),
            this, SLOT(localDeviceChanged(QBluetoothLocalDevice::HostMode)));

    _uuid = QBluetoothUuid(QString("94f39d29-7d6d-437d-973b-fba39e49d4ee"));
}


BTService::~BTService()
{}


void BTService::checkBluetoothOn()
{
    if ( _localDevice->isValid() )
    {
        // Turn Bluetooth on
        _localDevice->powerOn();
        _localDevice->setHostMode( QBluetoothLocalDevice::HostConnectable );
    }
    else
    {
        emit bluetoothModeChanged( QBluetoothLocalDevice::HostPoweredOff );
    }
}


void BTService::localDeviceChanged( QBluetoothLocalDevice::HostMode state )
{
    emit bluetoothModeChanged(state);
}


void BTService::serviceSearch(const QString& address)
{
    _foundPiBlasterService = false;


    if ( _control )
    {
        emit bluetoothMessage("Disconnecting from service...");
        _control->disconnectFromDevice();
        delete _control;
        _control = 0;
    }

    emit bluetoothMessage("Scanning for PiBlaster service...");

    _control = new QLowEnergyController(QBluetoothAddress(address), this );
    connect(_control, SIGNAL(serviceDiscovered(QBluetoothUuid)),
            this, SLOT(serviceDiscovered(QBluetoothUuid)));
    connect(_control, SIGNAL(discoveryFinished()),
            this, SLOT(serviceScanDone()));
    connect(_control, SIGNAL(error(QLowEnergyController::Error)),
            this, SLOT(controllerError(QLowEnergyController::Error)));
    connect(_control, SIGNAL(connected()), this, SLOT(deviceConnected()));
    connect(_control, SIGNAL(disconnected()), this, SLOT(deviceDisconnected()));

    _control->connectToDevice();
}


void BTService::deviceConnected()
{
    emit bluetoothError("Connected to remote...");
    _control->discoverServices();
}


void BTService::deviceDisconnected()
{
    emit bluetoothError("Connection reset by remote device!");
}


void BTService::serviceDiscovered(const QBluetoothUuid& gatt)
{
    if ( gatt == _uuid )
    {
        emit bluetoothMessage("Found PiBlaster service... Waiting for scan to finish.");
        _foundPiBlasterService = true;
    }
}

void BTService::serviceScanDone()
{
    delete _service;
    _service = 0;

    if ( _foundPiBlasterService )
    {
        emit bluetoothMessage("Connecting to service...");
        _service = _control->createServiceObject( _uuid, this );
    }

    if ( ! _service )
    {
        emit bluetoothError("PiBlaster Service not found.");
        return;
    }

    connect(_service, SIGNAL(stateChanged(QLowEnergyService::ServiceState)),
            this, SLOT(serviceStateChanged(QLowEnergyService::ServiceState)));
    connect(_service, SIGNAL(characteristicChanged(QLowEnergyCharacteristic,QByteArray)),
            this, SLOT(characteristicChanged(QLowEnergyCharacteristic,QByteArray)));
    connect(_service, SIGNAL(descriptorWritten(QLowEnergyDescriptor,QByteArray)),
            this, SLOT(confirmedDescriptorWrite(QLowEnergyDescriptor,QByteArray)));
    connect(_service, SIGNAL(error(QLowEnergyService::ServiceError)),
            this, SLOT(serviceError(QLowEnergyService::ServiceError)));
    _service->discoverDetails();
}


void BTService::disconnectService()
{
    _foundPiBlasterService = false;
    _control->disconnectFromDevice();
    delete _service;
    _service = 0;

    emit bluetoothMessage("Disconnected service.");
}


void BTService::controllerError(QLowEnergyController::Error error)
{
    qDebug() << "BTService::controllerError(): " << error;
    switch (error)
    {
    case QLowEnergyController::NoError:
        break;
    case QLowEnergyController::UnknownRemoteDeviceError:
        emit bluetoothError("Controller Error: Unkwown remote device!");
        break;
    case QLowEnergyController::NetworkError:
        emit bluetoothError("Controller Error: Network error!");
        break;
    case QLowEnergyController::InvalidBluetoothAdapterError:
        emit bluetoothError("Controller Error: Bluetooth adapter error!");
        break;
    default:
        emit bluetoothError("Controller Error: unkown controller error!");
    }
}


void BTService::serviceStateChanged(QLowEnergyService::ServiceState s)
{
    emit bluetoothMessage(QString("Service state changed: ")+QString::number(s));
}

void BTService::serviceError(QLowEnergyService::ServiceError error)
{
    qDebug() << "BTService::serviceError(): " << error;
    switch (error) {
    case QLowEnergyService::NoError:
        break;
    case QLowEnergyService::OperationError:
        emit bluetoothError("Service error: operation error!");
        break;
    case QLowEnergyService::CharacteristicWriteError:
        emit bluetoothError("Service error: Failed to set characteristic!");
        break;
    case QLowEnergyService::DescriptorWriteError:
        emit bluetoothError("Service error: Failed to set descriptor!");
        break;
    default:
        emit bluetoothError("Service error: unknown error!");
    }
}

void BTService::characteristicChanged(const QLowEnergyCharacteristic &c,
                                      const QByteArray &value)
{
    // ignore any other characteristic change -> shouldn't really happen though
    if ( c.uuid() != _uuid )
        return;

    qDebug() << value.constData();
}

void BTService::confirmedDescriptorWrite(const QLowEnergyDescriptor &d,
                                         const QByteArray &value)
{
    qDebug() << value.constData();
}


