TEMPLATE = app
QT += declarative
TARGET = "xmcr"
DEPENDPATH += .
INCLUDEPATH += .

# although the app doesn't use meegotouch by itself
# linking against it removes several style warnings
CONFIG += meegotouch

# enable booster
CONFIG += qt-boostable qdeclarative-boostable

# booster flags
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

# Input
SOURCES += main.cpp
OTHER_FILES += \
    qml/main.qml \
    qml/MainPage.qml \
    qml/workerscript.js \
    qml/Header.qml \
    qml/XMCR.js \
    qml/AboutView.qml \
    qml/ZoomableImage.qml \
    qml/HomeView.qml \
    qml/CommonToolBar.qml

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

    INSTALLS += target desktop icon64 splash

    target.path =$$BINDIR

    desktop.path = $$DATADIR/applications
    desktop.files += $${TARGET}.desktop

    icon64.path = $$DATADIR/icons/hicolor/64x64/apps
    icon64.files += ../data/$${TARGET}.png

    splash.path = $$DATADIR/$${TARGET}/
    splash.files += ../data/xmcr-splash-landscape.jpg
    splash.files += ../data/xmcr-splash-portrait.jpg
}



