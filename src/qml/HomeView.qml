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

    TabbedToolBar { id: tabbedTools }
    ArchiveView { id: archiveView }
    ArchiveView { id: favoritesView }

    Component.onCompleted: {
        archiveTab.push(archiveView, { filterFavorites: false })
        favoritesTab.push(favoritesView, { filterFavorites: true })
    }
}
