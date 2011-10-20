import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    id: commonTools

    signal jumpToFirstEntry()
    signal jumpToLastEntry()

    Component {
        id: aboutView
        AboutView { }
    }

    ButtonRow {
        TabButton {
            tab: archiveTab
            iconSource: 'image://theme/icon-m-toolbar-list'
        }
        TabButton {
            tab: favoritesTab
            iconSource: 'image://theme/icon-m-toolbar-favorite-mark'
        }
    }

    ToolIcon {
        Menu {
            id: mainMenu
            MenuLayout {
                MenuItem {
                    id: aboutEntry
                    text: 'About'
                    onClicked: {
                        appWindow.pageStack.push(aboutView)
                    }
                }
                MenuItem {
                    id: goToFirst
                    text: 'Go to first'
                    onClicked: jumpToFirstEntry()
                }
                MenuItem {
                    id: goToLast
                    text: 'Go to last'
                    onClicked: jumpToLastEntry()
                }
            }
        }
        iconId: 'icon-m-toolbar-view-menu'
        anchors.right: parent.right
        onClicked: (mainMenu.status == DialogStatus.Closed) ?
                       mainMenu.open() : mainMenu.close()
    }
}
