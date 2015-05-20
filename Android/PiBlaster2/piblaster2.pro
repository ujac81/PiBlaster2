QT += qml quick bluetooth
TARGET = PiBlaster2
!no_desktop: QT += widgets

include(src/src.pri)

OTHER_FILES += \
    android/AndroidManifest.xml \
    qml/main.qml \
    qml/MainMenuBar.qml \
    qml/BT.js \
    qml/UI.js \
    qml/BrowseDelegate.qml \
    qml/BrowseModel.qml \
    qml/BrowsePage.qml \
    qml/connect/ConnectPage.qml \
    qml/connect/ConnectTab.qml \
    qml/connect/SettingsTab.qml \
    qml/content/AndroidDelegate.qml \
    qml/play/PlayPage.qml \
    qml/play/PlayTab.qml \
    qml/play/VolumeTab.qml \
    qml/play/EqualizerTab.qml \
    qml/playlist/PlayListDelegate.qml \
    qml/playlist/PlayListModel.qml \
    qml/playlist/PlayListPage.qml \
    qml/dialogs/NoBluetoothDialog.qml \
    qml/items/FlickText.qml \
    qml/items/ScrollBar.qml
#    qml/content/ListPage.qml \
#    qml/content/ProgressBarPage.qml \
#    qml/content/SliderPage.qml \
#    qml/content/TabBarPage.qml \
#    qml/content/TextInputPage.qml

RESOURCES += \
    resources.qrc

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

#DISTFILES += \
#    qml/playlist/PlayListPage.qml \
#    qml/playlist/PlayListModel.qml \
#    qml/playlist/PlayListDelegate.qml

