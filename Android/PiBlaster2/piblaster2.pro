QT += qml quick bluetooth
TARGET = PiBlaster2
!no_desktop: QT += widgets

include(src/src.pri)

#OTHER_FILES += \
#    qml/main.qml \
#    qml/connect/ConnectPage.qml \
#    qml/connect/ConnectTab.qml \
#    qml/connect/SettingsTab.qml \
#    qml/content/AndroidDelegate.qml \
#    qml/content/ButtonPage.qml \
#    qml/content/ListPage.qml \
#    qml/content/ProgressBarPage.qml \
#    qml/content/SliderPage.qml \
#    qml/content/TabBarPage.qml \
#    qml/content/TextInputPage.qml

RESOURCES += \
    resources.qrc

#DISTFILES += \
#    qml/items/FlickText.qml


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
