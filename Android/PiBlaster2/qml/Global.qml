

import QtQuick 2.4
import QtQuick.Window 2.2

QtObject {

    id: global

    property real dp: Screen.pixelDensity

    property int sizeToolbar: Math.floor(dp * 8)


}

