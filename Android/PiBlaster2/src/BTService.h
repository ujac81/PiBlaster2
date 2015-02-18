
#ifndef BTService_H
#define BTService_H

#include "BTCommMessageHandler.h"


#include <QString>
#include <QDebug>
#include <QDateTime>
#include <QVector>
#include <QTimer>
#include <QBluetoothDeviceInfo>
#include <QBluetoothLocalDevice>
#include <QBluetoothServiceDiscoveryAgent>
#include <QBluetoothServiceInfo>
#include <QBluetoothSocket>


QT_USE_NAMESPACE
class BTService: public QObject
{
    Q_OBJECT

public:
    BTService(BTCommMessageHandler* msgHandler);
    ~BTService();

public slots:

    /**
     * @brief Check if bluetooth is on, request turn on otherwise.
     * TODO: emits bluetoothOff() if bluetooth is not on
     */
    void checkBluetoothOn();

    void serviceSearch(const QString& address);
    void stopServiceSearch();
    void disconnectService();


    void writeSocket(const QString& msg);

private slots:

    void serviceDiscovered(const QBluetoothServiceInfo& info);
    void serviceScanFinished();
    void serviceError(QBluetoothServiceDiscoveryAgent::Error error);
    void serviceScanStopped();


    void readSocket();
    void socketConnected();
    void socketDisconnected();
    void socketError(QBluetoothSocket::SocketError error);



    /// @brief Triggered if state of local bluetooth device changed.
    void localDeviceChanged(QBluetoothLocalDevice::HostMode state);

Q_SIGNALS:

    void bluetoothError(const QString&);
    void bluetoothMessage(const QString&);
    void bluetoothModeChanged(QBluetoothLocalDevice::HostMode state);

    void bluetoothConnected();
    void bluetoothDisconnected();


private:
    BTCommMessageHandler* _msgHandler;
    QBluetoothLocalDevice* _localDevice;
    QBluetoothUuid _uuid;

    bool _foundPiBlasterService;
    QBluetoothServiceDiscoveryAgent* _discovery;
    QBluetoothServiceInfo _serviceInfo;

    QBluetoothSocket* _socket;

    int _msgId;

};

#endif // BTService_H
