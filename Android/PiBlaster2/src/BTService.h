
#ifndef BTService_H
#define BTService_H

#include "BTCommMessageHandler.h"


#include <QString>
#include <QDebug>
#include <QDateTime>
#include <QVector>
#include <QTimer>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>
#include <QBluetoothLocalDevice>
#include <QBluetoothServiceDiscoveryAgent>
#include <QBluetoothServiceInfo>
#include <QBluetoothSocket>
#include <QLowEnergyController>


QT_USE_NAMESPACE
class BTService: public QObject
{
    Q_OBJECT

public:
    BTService(BTCommMessageHandler* msgHandler);
    ~BTService();


    Q_INVOKABLE QBluetoothLocalDevice::HostMode hostMode() const { return _hostMode; }

public slots:

    /**
     * @brief Check if bluetooth is on, request turn on otherwise.
     * TODO: emits bluetoothOff() if bluetooth is not on
     */
    void checkBluetoothOn();

    bool checkPairing(const QString& address);

    /**
     * @brief Check if devices are paired, requests pairing if not.
     * Will emit bluetoothPaired after pairing
     * @param address
     */
    void requestPairing(const QString& address);

    void serviceSearch(const QString& address);
    void stopServiceSearch();
    void disconnectService();


    void writeSocket(const QString& msg);


    /**
     * @brief Clear send payload buffer.
     * To be used before writeSocketWithPayload() and addToSendPayload().
     * Send payload is used for commands with multiple lines
     * like playlist add commands.
     */
    void clearSendPayload() { _sendPayload.clear(); }

    /**
     * @brief Add a line to send payload.
     * To be used before execCommandWithPayload().
     */
    void addToSendPayload( const QString& add ) { _sendPayload.append( add ); }

    /**
     * @brief Send command with prepared payload to PyBlaster via bluetooth.
     * Fire up new RFCommSendThread to send message.
     * Message will be received by RFCommRecvThread which will emit signal.
     */
    void writeSocketWithPayload( const QString& command );

private slots:

    void serviceDiscovered(const QBluetoothServiceInfo& info);
    void serviceScanFinished();
    void serviceError(QBluetoothServiceDiscoveryAgent::Error error);
    void serviceScanStopped();

    void lowEnergyServiceDiscovered(QBluetoothUuid);
    void lowEnergyServiceScanFinished();
    void lowEnergyServiceError(QLowEnergyController::Error error);
    void lowEnergyDeviceConnected();
    void lowEnergyDeviceDisconnected();


    void readSocket();
    void socketConnected();
    void socketDisconnected();
    void socketError(QBluetoothSocket::SocketError error);
    void socketStateChanged(QBluetoothSocket::SocketState state);

    /// @brief Triggered if state of local bluetooth device changed.
    void localDeviceChanged(QBluetoothLocalDevice::HostMode state);

    /// @brief Triggered after local device is paired
    void localDevicePaired(const QBluetoothAddress& address,
                           QBluetoothLocalDevice::Pairing pairing);

Q_SIGNALS:

    void bluetoothError(const QString&);
    void bluetoothWarning(const QString&);
    void bluetoothMessage(const QString&);
    void bluetoothModeChanged(QBluetoothLocalDevice::HostMode state);
    void bluetoothPaired(const QBluetoothAddress& address,
                         QBluetoothLocalDevice::Pairing pairing);

    void bluetoothConnected();
    void bluetoothDisconnected();


private:
    BTCommMessageHandler* _msgHandler;
    QBluetoothLocalDevice* _localDevice;
    QBluetoothUuid _uuid;

    bool _foundPiBlasterService;
    QBluetoothServiceDiscoveryAgent* _discovery;
    QBluetoothServiceInfo _serviceInfo;

    QLowEnergyController* _control;

    QBluetoothDeviceDiscoveryAgent* _agent;
    bool _deviceFound;

    QBluetoothSocket* _socket;

    int _msgId;

    QBluetoothLocalDevice::HostMode _hostMode;

    QList<QString> _sendPayload;

};

#endif // BTService_H
