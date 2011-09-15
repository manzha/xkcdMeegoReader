#include <QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QDeclarativeView view;

    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.showFullScreen();

    return app.exec();
}
