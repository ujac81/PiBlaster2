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
    qml/browse/BrowseDelegate.qml \
    qml/browse/BrowseModel.qml \
    qml/browse/BrowsePage.qml \
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
    qml/items/ScrollBar.qml \
    qml/search/SearchPage.qml \
    qml/search/SearchModel.qml \
    qml/search/SearchDelegate.qml \
    qml/search/SearchView.qml \
    qml/upload/UploadPage.qml \
    qml/upload/UploadModel.qml \
    qml/upload/UploadDelegate.qml

RESOURCES += \
    resources.qrc

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

#DISTFILES += \
#    qml/playlist/PlayListPage.qml \
#    qml/playlist/PlayListModel.qml \
#    qml/playlist/PlayListDelegate.qml

