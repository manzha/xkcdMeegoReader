import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    id: commonTools

    ToolIcon {
        iconId: enabled ? 'toolbar-back' : 'toolbar-back-dimmed'
        enabled: (tabGroup.currentTab !== undefined && tabGroup.currentTab.depth > 1)
        onClicked: tabGroup.currentTab.pop()
    }

    ButtonRow {
        TabButton {
            tab: welcomeTab
            iconSource: (tabGroup.currentTab != welcomeTab ?
                             'image://theme/icon-m-toolbar-home' :
                             'image://theme/icon-m-toolbar-home-selected')

        }
        TabButton {
            tab: favoritesTab
            iconSource: (tabGroup.currentTab != favoritesTab ?
                             'image://theme/icon-m-toolbar-favorite-mark' :
                             'image://theme/icon-m-toolbar-favorite-mark-selected')
        }
        TabButton {
            tab: archiveTab
            iconSource: (tabGroup.currentTab != archiveTab ?
                             'image://theme/icon-m-toolbar-list' :
                             'image://theme/icon-m-toolbar-list-selected')
        }
    }

    ToolIcon {
        iconId: 'icon-m-toolbar-view-menu'
    }
}
