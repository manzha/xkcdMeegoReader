import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    tools: tabbedTools

    TabGroup {
        id: tabGroup
        currentTab: archiveTab

        PageStack {
            id: archiveTab
        }

        PageStack {
            id: favoritesTab
        }
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem {
                id: aboutEntry
                text: 'About'
                onClicked: appWindow.pageStack.push(aboutView)
            }
            MenuItem {
                id: goToFirst
                text: 'Go to first'
                onClicked: tabGroup.currentTab.currentPage.jumpToFirst()
            }
            MenuItem {
                id: goToLast
                text: 'Go to last'
                onClicked: tabGroup.currentTab.currentPage.jumpToLast()
            }
        }
    }
    TabbedToolBar {
        id: tabbedTools
        onShowMenu: (mainMenu.status == DialogStatus.Closed) ?
                        mainMenu.open() : mainMenu.close()
    }
    ArchiveView { id: archiveView }
    ArchiveView { id: favoritesView }
    Component { id: aboutView; AboutView { } }

    Component.onCompleted: {
        archiveTab.push(archiveView, { filterFavorites: false })
        favoritesTab.push(favoritesView, { filterFavorites: true })
    }
}
