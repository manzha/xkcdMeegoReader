import QtQuick 1.1
import com.nokia.meego 1.0

PageStackWindow {
    id: appWindow

    initialPage: mainPage
    showStatusBar: appWindow.inPortrait

    HomeView { id: mainPage }
    ComicView { id: comicView }
}
