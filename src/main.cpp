#include "controller.h"
#include <QApplication>
#include <QDeclarativeView>
#ifndef QT_SIMULATOR
    #include <MDeclarativeCache>
#endif
#include <QDeclarativeContext>
#include <QTranslator>
#include <QTextCodec>
#include <QLocale>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifndef QT_SIMULATOR
    QApplication *app = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *view = MDeclarativeCache::qDeclarativeView();
#else
    QApplication *app = new QApplication(argc, argv);
    QDeclarativeView *view = new QDeclarativeView;
#endif
    app->setApplicationName("XMCR");
    app->setOrganizationDomain("com.simonpena");
    app->setOrganizationName("simonpena");

    // Assume that strings in source files are UTF-8
    QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));

    QString locale(QLocale::system().name());
    QTranslator translator;

    if (translator.load("l10n/xmcr." + locale, ":/")) {
        app->installTranslator(&translator);
    }

    QDeclarativeContext *context = view->rootContext();

    Controller *controller = new Controller(context);

    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->showFullScreen();

    int result = app->exec();

    delete controller;
    delete view;
    delete app;

    return result;
}
