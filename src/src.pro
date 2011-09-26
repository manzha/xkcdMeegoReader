TEMPLATE = app
QT += declarative
CONFIG += meegotouch
TARGET = "xmcr"
DEPENDPATH += .
INCLUDEPATH += .

# Input
SOURCES += main.cpp
OTHER_FILES += \
    qml/main.qml \
    qml/MainPage.qml \
    qml/workerscript.js \
    qml/Header.qml

RESOURCES += \
    res.qrc

unix {
    #VARIABLES
    isEmpty(PREFIX) {
        PREFIX = /usr
    }
    BINDIR = $$PREFIX/bin
    DATADIR =$$PREFIX/share

    DEFINES += DATADIR=\\\"$$DATADIR\\\" PKGDATADIR=\\\"$$PKGDATADIR\\\"

    #MAKE INSTALL

    INSTALLS += target desktop icon64

    target.path =$$BINDIR

    desktop.path = $$DATADIR/applications
    desktop.files += $${TARGET}.desktop

    icon64.path = $$DATADIR/icons/hicolor/64x64/apps
    icon64.files += ../data/$${TARGET}.png
}
