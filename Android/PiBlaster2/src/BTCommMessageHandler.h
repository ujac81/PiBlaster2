#ifndef BTCommMessageHandler_H
#define BTCommMessageHandler_H

#include <map>

#include <QQmlEngine>
#include <QGuiApplication>
#include <QObject>
#include <QVariant>
#include <QDebug>
#include <qqml.h>

#include "BTMessage.h"



class BTCommMessageHandler : public QObject
{
    Q_OBJECT
public:

    /**
     * @brief Init QObject and set some signals
     * @param parent viewer object
     * @param app pointer to GUI event queue
     */
    explicit BTCommMessageHandler( QObject* parent = 0 );

    ~BTCommMessageHandler();

    /**
     * @brief Check if bluetooth is on, request turn on otherwise.
     * Emits bluetoothOff() if bluetooth is not on
     */
    Q_INVOKABLE void checkBluetoothOn();


public slots:

    Q_INVOKABLE void bufferLine( const QString& line );


signals:

    void receivedMessage( BTMessage* );


private:

    void messageDone( int id, BTMessage* msg );
    BTMessage* newMessageObject( int id, int status, int code, int plSize, const QString& msg );

    std::map<int, BTMessage*>           _recvBuffer;

};

#endif // BTCommMessageHandler_H


