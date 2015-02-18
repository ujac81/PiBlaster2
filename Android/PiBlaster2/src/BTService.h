
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
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QBluetoothServiceDiscoveryAgent>

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


    void serviceSearch( const QString& address );

    void disconnectService();

private slots:


    //QLowEnergyController
    /// @brief Called by _control on serviceDiscovered().
    void serviceDiscovered(const QBluetoothUuid&);
    /// @brief Called by _control on discoveryFinished().
    void serviceScanDone();
    /// @brief Called by _control on error.
    void controllerError(QLowEnergyController::Error);
    /// @brief Called by _control on connected().
    void deviceConnected();
    /// @brief Called by _control on disconnected().
    void deviceDisconnected();

    //QLowEnergyService
    /// @brief Called by _service on stateChanged().
    void serviceStateChanged(QLowEnergyService::ServiceState s);
    /// @brief Called by _service on stateChanged().
    void characteristicChanged(const QLowEnergyCharacteristic &c,
                               const QByteArray &value);
    /// @brief Called by _service on descriptorWritten().
    void confirmedDescriptorWrite(const QLowEnergyDescriptor &d,
                                  const QByteArray &value);
    /// @brief Called by _service on error.
    void serviceError(QLowEnergyService::ServiceError e);


    /// @brief Triggered if state of local bluetooth device changed.
    void localDeviceChanged(QBluetoothLocalDevice::HostMode state);

Q_SIGNALS:

    void bluetoothError(const QString&);
    void bluetoothMessage(const QString&);
    void bluetoothModeChanged(QBluetoothLocalDevice::HostMode state);


private:
    BTCommMessageHandler* _msgHandler;
    QBluetoothLocalDevice* _localDevice;
    QBluetoothUuid _uuid;

    bool _foundPiBlasterService;
    QLowEnergyController *_control;
    QLowEnergyService *_service;
};

#endif // BTService_H
