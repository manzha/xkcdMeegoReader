import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    tools: commonTools

    TabGroup {
        id: tabGroup
        currentTab: welcomeTab

        PageStack {
            id: welcomeTab
        }

        PageStack {
            id: archiveTab
        }

        PageStack {
            id: favoritesTab
        }
    }

    CommonToolBar { id: commonTools }
    MainPage { id: mainPage }

    Component.onCompleted: {
        welcomeTab.push(mainPage)
    }
}
