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

public slots:

    Q_INVOKABLE void bufferLine( const QString& line );

    Q_INVOKABLE void clearAll();


signals:

    void receivedMessage( BTMessage* );


private:

    void messageDone( int id, BTMessage* msg );
    BTMessage* newMessageObject( int id, int status, int code, int plSize, const QString& msg );

    std::map<int, BTMessage*>           _recvBuffer;

};

#endif // BTCommMessageHandler_H


