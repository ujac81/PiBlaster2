
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QQmlContext>

#include "BTCommMessageHandler.h"
#include "BTMessage.h"


int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    qRegisterMetaType<BTMessage>( "BTMessage" );

    BTCommMessageHandler* btMessages = new BTCommMessageHandler();
    btMessages->checkBluetoothOn();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("btMessages", btMessages);
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}


