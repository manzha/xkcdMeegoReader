import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    signal showMenu()

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
        iconId: 'icon-m-toolbar-view-menu'
        anchors.right: parent.right
        onClicked: showMenu()
    }
}
