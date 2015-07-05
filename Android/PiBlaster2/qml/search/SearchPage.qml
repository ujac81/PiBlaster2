
import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

import "../UI.js" as UI


Item {

    objectName: "SearchPage"

    Row {

        spacing: main.sizeVerticalSpacing
        id: searchBox
        width: parent.width
        height: main.sizeFontHead + 5 * main.sizeMargin

        Text {
            id: searchtext
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignBottom
            anchors.margins: 2*main.sizeMargin
            font.pixelSize: main.sizeFontHead
            text: "Search: "
            color: "white"
        }

        TextField {
            focus: false
            id: macTextField
            anchors.margins: 2*main.sizeMargin
            text: ''
            style: touchStyle
            width: parent.width - searchtext.width - 2*2*2*main.sizeMargin
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
        height: parent.height - main.sizeFontHead + 5 * main.sizeMargin
        anchors.top: searchBox.bottom
    }


    Component {
        id: touchStyle

        TextFieldStyle {
            textColor: "white"
            font.pixelSize: main.sizeFontHead
            background: Item {
                implicitHeight: main.sizeButton
                implicitWidth: main.sizeButtonWidth
                BorderImage {
                    source: "/images/textinput.png"
                    border.left: main.sizeMargins
                    border.right: main.sizeMargins
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

