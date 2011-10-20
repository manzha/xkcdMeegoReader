import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    id: commonTools

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
        iconId: 'icon-m-toolbar-description'
        anchors.right: parent.right
        onClicked: appWindow.pageStack.push(aboutView)
    }
}
