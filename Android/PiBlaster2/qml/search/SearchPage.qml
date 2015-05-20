
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI


Item {

    objectName: "SearchPage"

    Row {

        spacing: 40
        id: searchBox
        width: parent.width
        height: 100

        Text {
            id: searchtext
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            anchors.margins: 20
            font.pixelSize: 28
            text: "Search: "
            color: "white"
        }

        TextField {
            focus: false
            id: macTextField
            anchors.margins: 20
            text: ''
            style: touchStyle
            width: parent.width - searchtext.width - 80
            onAccepted: {
                if (text.length < 4 ) {
                    UI.setStatus("Search string requires at least 3 charackters!");
                } else {
                    UI.btSendSingle("searchfile -"+text+"-");
                }
            }
        }
    }


    SearchView {

        id: searchscrollview

        width: parent.width
        height: parent.height - 100
        anchors.top: searchBox.bottom

    }


    Component {
        id: touchStyle

        TextFieldStyle {
            textColor: "white"
            font.pixelSize: 28
            background: Item {
                implicitHeight: 50
                implicitWidth: 320
                BorderImage {
                    source: "/images/textinput.png"
                    border.left: 8
                    border.right: 8
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        }
    }

    function update_search(msg) {
        searchscrollview.update_search(msg);
    }

    function search_action(action_name) {
        searchscrollview.search_action(action_name);
    }

    function activated() {}

}

