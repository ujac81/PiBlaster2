

#include <QBluetoothLocalDevice>
#include <QString>

#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>


int main(int argc, char *argv[])
{
    QBluetoothLocalDevice localDevice;

    if (localDevice.isValid())
    {
        // Turn Bluetooth on
        localDevice.powerOn();
        localDevice.setHostMode(QBluetoothLocalDevice::HostConnectable);
    }

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/qml/main.qml"));
    return app.exec();


    if (localDevice.isValid())
    {
        // Turn Bluetooth off
        localDevice.setHostMode(QBluetoothLocalDevice::HostPoweredOff);
    }
}
