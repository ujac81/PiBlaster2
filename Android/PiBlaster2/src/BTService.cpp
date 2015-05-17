
#include "BTService.h"

#include <QBluetoothAddress>

BTService::BTService(BTCommMessageHandler* msgHandler):
    QObject(),
    _msgHandler(msgHandler),
    _foundPiBlasterService(false),
    _discovery(0),
    _socket(0),
    _msgId(0)
{
    _localDevice = new QBluetoothLocalDevice(this);
    _hostMode = QBluetoothLocalDevice::HostPoweredOff;

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
        if ( _localDevice->hostMode() != QBluetoothLocalDevice::HostConnectable )
        {
            // Turn Bluetooth on
            _localDevice->powerOn();
            _localDevice->setHostMode( QBluetoothLocalDevice::HostConnectable );
        } else {
            _hostMode = QBluetoothLocalDevice::HostConnectable;
            emit bluetoothModeChanged( QBluetoothLocalDevice::HostConnectable );
        }
    }
    else
    {
        emit bluetoothModeChanged( QBluetoothLocalDevice::HostPoweredOff );
    }
}


void BTService::localDeviceChanged( QBluetoothLocalDevice::HostMode state )
{
    _hostMode = state;
    emit bluetoothModeChanged(state);
}


void BTService::serviceSearch(const QString& address)
{
    disconnectService();

    emit bluetoothMessage( "Scanning for PiBlaster service..." );

    _discovery = new QBluetoothServiceDiscoveryAgent(this );
    _discovery->setRemoteAddress( QBluetoothAddress(address) );
    _discovery->setUuidFilter( _uuid );

    connect(_discovery, SIGNAL(canceled()), this, SLOT(serviceScanStopped()));
    connect(_discovery, SIGNAL(finished()), this, SLOT(serviceScanFinished()));
    connect(_discovery, SIGNAL(error(QBluetoothServiceDiscoveryAgent::Error)),
            this, SLOT(serviceError(QBluetoothServiceDiscoveryAgent::Error)));
    connect(_discovery, SIGNAL(serviceDiscovered(QBluetoothServiceInfo)),
            this, SLOT(serviceDiscovered(QBluetoothServiceInfo)));

    _discovery->start();
}


void BTService::disconnectService()
{
    _foundPiBlasterService = false;
    _msgId = 0;

    if ( _discovery )
    {
        emit bluetoothMessage("Disconnect: Deleting discovery agent...");
        _discovery->stop();
        delete _discovery;
        _discovery = 0;
    }

    if ( _socket )
    {
        emit bluetoothMessage("Disconnect: Wiping out socket...");
        _socket->disconnectFromService();
        delete _socket;
        _socket = 0;
    }

    emit bluetoothMessage("Disconnected service.");
}


void BTService::stopServiceSearch()
{
    if ( _discovery )
    {
        emit bluetoothMessage("Discovery: Stopping discovery agent...");
        _discovery->stop();
        delete _discovery;
        _discovery = 0;
    }
}


void BTService::serviceScanStopped()
{
    emit bluetoothMessage("Stop scan: Deleting discovery agent...");
    disconnectService();
}


void BTService::serviceError(QBluetoothServiceDiscoveryAgent::Error error)
{
    qDebug() << "BTService::serviceError(): " << error;
    switch (error) {
    case QBluetoothServiceDiscoveryAgent::NoError:
        break;
    case QBluetoothServiceDiscoveryAgent::PoweredOffError:
        emit bluetoothError("Discovery error: adapter has been powered off while scanning!");
        break;
    case QBluetoothServiceDiscoveryAgent::InputOutputError:
        emit bluetoothError("Discovery error: I/O error!");
        break;
    case QBluetoothServiceDiscoveryAgent::InvalidBluetoothAdapterError:
        emit bluetoothError("Discovery error: Invalid adapter!");
        break;
    default:
        emit bluetoothError("Discovery error: unknown error!");
    }
}


void BTService::serviceDiscovered( const QBluetoothServiceInfo& info )
{
    //if ( info.serviceUuid() == _uuid )
    {
        emit bluetoothMessage("Found PiBlaster service... Waiting for scan to finish.");
        _foundPiBlasterService = true;
        _serviceInfo = info;
    }
}


void BTService::serviceScanFinished()
{
    if ( _foundPiBlasterService )
    {
        emit bluetoothMessage("Connecting to service...");

        _socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

        // TODO: catch I/O errors on socket

        connect(_socket, SIGNAL(connected()), this, SLOT(socketConnected()));
        connect(_socket, SIGNAL(disconnected()), this, SLOT(socketDisconnected()));
        connect(_socket, SIGNAL(error(QBluetoothSocket::SocketError)),
                this, SLOT(socketError(QBluetoothSocket::SocketError)));
        connect(_socket, SIGNAL(readyRead()), this, SLOT(readSocket()));
        connect(_socket, SIGNAL(stateChanged(QBluetoothSocket::SocketState)),
                this, SLOT(socketStateChanged(QBluetoothSocket::SocketState)));

        _socket->connectToService( _serviceInfo );
    } else {
        emit bluetoothError("PiBlaster Service not found.");
        return;
    }
}


void BTService::socketConnected()
{
    emit bluetoothMessage("Connected to service...");
    emit bluetoothConnected();
}


void BTService::socketDisconnected()
{
    emit bluetoothMessage("Disconnected from service...");
    emit bluetoothDisconnected();
}


void BTService::socketError(QBluetoothSocket::SocketError error)
{
    qDebug() << "BTService::socketError(): " << error;
    switch (error) {
    case QBluetoothSocket::NoSocketError:
        break;
    case QBluetoothSocket::NetworkError:
        emit bluetoothError("Socket error: network error!");
        break;
    case QBluetoothSocket::OperationError:
        emit bluetoothError("Socket error: operation error!");
        break;
    default:
        emit bluetoothError("Socket error: unknown error!");
    }
}


void BTService::socketStateChanged(QBluetoothSocket::SocketState state)
{
    qDebug() << "BTService::socketStateChanged(): " << state;
}


void BTService::readSocket()
{
    if ( ! _socket )
        return;

    while ( _socket->canReadLine() )
    {
        QByteArray line = _socket->readLine();
        QString sline = QString::fromUtf8( line.constData(), line.length() );
        _msgHandler->bufferLine( sline );

//        // write '1' to buffer to tell PiBlaster to send next line.
//        // TODO: redesign
//        QByteArray text = QString("1").toUtf8() + '\n';
//        qint64 bytes = _socket->write( text );
//        if ( bytes == -1 )
//        {
//            emit bluetoothWarning("Write to bluetooth socket failed. Disconnecting from service!");
//            disconnectService();
//        }
    }
}


void BTService::writeSocket( const QString &msg )
{
    if ( ! _socket )
        return;

    QString line = QString::number( _msgId ) + " 0 " + msg;
    QString head = QString("%1").arg( line.length(), 4, 10, QLatin1Char('0') );
    QString send = head + line;
    if ( msg != "keepalive" )
        qDebug() << "SEND: " << send;
    QByteArray text = send.toUtf8() + '\n';
    qint64 bytes = _socket->write( text );
    if ( bytes == -1 )
    {
        emit bluetoothWarning("Write to bluetooth socket failed. Disconnecting from service!");
        disconnectService();
    }

    _msgId++;
}


void BTService::writeSocketWithPayload(const QString& command)
{
    if ( ! _socket )
        return;

    QString line = QString::number( _msgId ) + " " +
            QString::number( _sendPayload.size() ) + " " + command;
    QString head = QString("%1").arg( line.length(), 4, 10, QLatin1Char('0') );
    QString send = head + line;
    QByteArray text = send.toUtf8() + '\n';
    qint64 bytes = _socket->write( text );
    if ( bytes == -1 )
    {
        emit bluetoothWarning("Write to bluetooth socket failed. Disconnecting from service!");
        disconnectService();
    }

    // TODO: thread this

    for ( int i = 0; i < _sendPayload.size(); ++i )
    {
        QString line = _sendPayload[i];
        QString head = QString("%1").arg(
                    QString::number( line.length()), 4, '0');

        QString send = head + line;
        QByteArray text = send.toUtf8() + '\n';
        qint64 bytes = _socket->write( text );
        if ( bytes == -1 )
        {
            emit bluetoothWarning("Write to bluetooth socket failed. Disconnecting from service!");
            disconnectService();
            break;
        }
    }

    _msgId++;
}



