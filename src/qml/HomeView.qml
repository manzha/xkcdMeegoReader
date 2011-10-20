import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    tools: commonTools

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

    CommonToolBar { id: commonTools }
    ArchiveView { id: archiveView }
    ArchiveView { id: favoritesView }

    Component.onCompleted: {
        archiveTab.push(archiveView, { filterFavorites: false })
        favoritesTab.push(favoritesView, { filterFavorites: true })
    }
}
