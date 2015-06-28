
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QQmlContext>
#include <QLoggingCategory>

#include "BTCommMessageHandler.h"
#include "BTMessage.h"
#include "BTService.h"


int main(int argc, char *argv[])
{
    QLoggingCategory::setFilterRules(QStringLiteral("qt.bluetooth* = true"));


    BTCommMessageHandler* btMessages = new BTCommMessageHandler();
    BTService* btService = new BTService(btMessages);
    btService->checkBluetoothOn();


    QGuiApplication app(argc, argv);
    qRegisterMetaType<BTMessage>( "BTMessage" );
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("btMessages", btMessages);
    engine.rootContext()->setContextProperty("btService", btService);
    engine.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));

    return app.exec();
}


