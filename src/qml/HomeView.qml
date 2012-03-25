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
                text: qsTr('About')
                onClicked: appWindow.pageStack.push(aboutView)
            }
            MenuItem {
                id: goToFirst
                text: qsTr('Jump to newest')
                onClicked: tabGroup.currentTab.currentPage.jumpToFirst()
            }
            MenuItem {
                id: goToLast
                text: qsTr('Jump to oldest')
                onClicked: tabGroup.currentTab.currentPage.jumpToLast()
            }
        }
    }
    TabbedToolBar {
        id: tabbedTools
        onShowMenu: (mainMenu.status === DialogStatus.Closed) ?
                        mainMenu.open() : mainMenu.close()
    }

    Component {
        id: archiveView
        ArchiveView { }
    }

    Component {
        id: favoritesView
        ArchiveView { storesFavorites: true }
    }

    Component { id: aboutView
        AboutView { }
    }

    Component.onCompleted: {
        archiveTab.push(archiveView)
        favoritesTab.push(favoritesView)
    }
}
