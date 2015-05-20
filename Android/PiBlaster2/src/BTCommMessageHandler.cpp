
#include <cassert>

#include <QString>

#include "BTCommMessageHandler.h"


BTCommMessageHandler::BTCommMessageHandler( QObject* parent ) :
    QObject( parent )
{}


BTCommMessageHandler::~BTCommMessageHandler()
{
    clearAll();
}


void BTCommMessageHandler::clearAll()
{
    for (std::map<int, BTMessage*>::iterator iter = _recvBuffer.begin();
         iter != _recvBuffer.end(); iter++ )
    {
        delete iter->second;
    }
    _recvBuffer.clear();
}


BTMessage* BTCommMessageHandler::newMessageObject( int id,
                                                   int status,
                                                   int code,
                                                   int plSize,
                                                   const QString& msg )
{
    assert( _recvBuffer.find( id ) == _recvBuffer.end() );

    BTMessage* newMsg = new BTMessage( id, status, code, plSize, msg );
    _recvBuffer[id] = newMsg;
    return newMsg;
}


void BTCommMessageHandler::messageDone( int id, BTMessage* msg )
{
    assert( _recvBuffer.find( id ) != _recvBuffer.end() );
    assert( msg->payloadComplete() );

    BTMessage msgCpy(*msg);
    delete msg;
    _recvBuffer.erase( id );
    msgCpy.preparePayloadElements();
    emit receivedMessage( &msgCpy );
}



void BTCommMessageHandler::bufferLine( const QString& lineIn )
{
    QString line = lineIn;

    // remove length header
    line.remove(0, 6);

    if ( line.length() < 4 ) return;

    if ( line.left(2) == "PL" )
    {
        // header is PL%4d % n_lines
        int lines = line.mid(2, 4).toInt();
        line.remove(0, 6);

        for ( int i = 0; i < lines; i++ )
        {
            int length = line.left(4).toInt();
            line.remove(0, 4);
            int id = line.left(4).toInt();
            line.remove(0, 4);
            QString subLine = line.left(length-4);
            line.remove(0, length-4);

            std::map<int, BTMessage*>::iterator iter = _recvBuffer.find( id );
            if ( iter != _recvBuffer.end() )
            {
                iter->second->addPayload( subLine.trimmed() );
                if ( iter->second->payloadComplete() )
                    messageDone( id, iter->second );
            }
            else
            {
                // error, no message object
            }
        }
    }
    else
    {
        // new instruction
        // 1st line should be [id status code payload_length message]
        int id = line.left(4).toInt();
        int status  = line.mid(4, 4).toInt();
        int code    = line.mid(8, 4).toInt();
        int plSize  = line.mid(12, 6).toInt();
        QString msg = line.right(line.length()-18).trimmed();
        BTMessage* msgObj = newMessageObject( id, status, code, plSize, msg );
        if ( msgObj->payloadComplete() )
            messageDone( id, msgObj );
    }
}


