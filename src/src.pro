TEMPLATE = app
QT += declarative webkit
TARGET = "xmcr"
DEPENDPATH += .
INCLUDEPATH += .

# although the app doesn't use meegotouch by itself
# linking against it removes several style warnings
CONFIG += meegotouch

# enable booster
CONFIG += qt-boostable qdeclarative-boostable

# Use share-ui interface
CONFIG += shareuiinterface-maemo-meegotouch mdatauri

# booster flags
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

# Input
SOURCES += main.cpp \
    sortfiltermodel.cpp \
    controller.cpp \
    comicentry.cpp \
    comicentrylistmodel.cpp \
    comicentryfetcher.cpp \
    imagesaver.cpp

HEADERS += \
    sortfiltermodel.h \
    controller.h \
    comicentry.h \
    comicentrylistmodel.h \
    comicentryfetcher.h \
    imagesaver.h

OTHER_FILES += \
    qml/main.qml \
    qml/workerscript.js \
    qml/Header.qml \
    qml/XMCR.js \
    qml/AboutView.qml \
    qml/ZoomableImage.qml \
    qml/HomeView.qml \
    qml/ComicView.qml \
    qml/ListSectionDelegate.qml \
    qml/EntryMenuDelegate.qml \
    qml/ArchiveView.qml \
    qml/RefreshHeader.qml \
    qml/TabbedToolBar.qml \
    qml/ComicToolBar.qml \
    qml/FastScroll.qml \
    qml/FastScrollStyle.qml \
    qml/FastScroll.js

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
