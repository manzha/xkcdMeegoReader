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
    qml/FastScroll.js \
    qml/constants.js

RESOURCES += \
    res.qrc

CODECFORTR = UTF-8
TRANSLATIONS += \
    l10n/xmcr.en.ts \
    l10n/xmcr.es.ts \
    l10n/xmcr.fr.ts \
    l10n/xmcr.pt.ts \
    l10n/xmcr.de.ts

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
    icon64.files += ../data/icon-l-$${TARGET}.png

    splash.path = $$DATADIR/$${TARGET}/
    splash.files += ../data/xmcr-splash-portrait.jpg
}

# Rule for regenerating .qm files for translations (missing in qmake
# default ruleset, ugh!)
#
updateqm.input = TRANSLATIONS
updateqm.output = ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.qm
updateqm.commands = lrelease ${QMAKE_FILE_IN} -qm ${QMAKE_FILE_OUT}
updateqm.CONFIG += no_link
QMAKE_EXTRA_COMPILERS += updateqm
PRE_TARGETDEPS += compiler_updateqm_make_all
