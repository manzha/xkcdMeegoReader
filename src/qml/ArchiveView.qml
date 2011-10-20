import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: mainPage

    property bool filterFavorites: false

    onStatusChanged: {
        if (status == PageStatus.Active) {
            entriesModel.setFavoritesFiltered(filterFavorites)
            entriesModel.setFilterWildcard(filterEntries.text)
        }
    }

    Component.onCompleted: {
        comicView.moveToNext.connect(showNext)
        comicView.moveToPrevious.connect(showPrevious)
        comicView.moveToRandom.connect(showRandom)
    }

    function showNext() {
        if (list.currentIndex > 0) {
            list.currentIndex --
            comicView.currentEntry = list.currentItem
        }
    }

    function showPrevious() {
        if (list.currentIndex < list.model.count) {
            list.currentIndex ++
            comicView.currentEntry = list.currentItem
        }
    }

    function showRandom() {
        list.currentIndex = XMCR.getRandomStripNumber(list.model.count + 1)
        comicView.currentEntry = list.currentItem
    }

    Header {
        id: topBar
        title: 'Archive'
        ToolIcon {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconId: 'icon-m-toolbar-refresh'
            onClicked: controller.fetchEntries()
        }
    }

    TextField {
        id: filterEntries
        anchors { top: topBar.bottom; left: parent.left; right: parent.right }
        anchors { topMargin: UIConstants.DEFAULT_MARGIN; leftMargin: UIConstants.DEFAULT_MARGIN; rightMargin: UIConstants.DEFAULT_MARGIN }
        placeholderText: 'Search'
        inputMethodHints: Qt.ImhNoPredictiveText

        onTextChanged: {
           entriesModel.setFilterWildcard(text)
        }

        Image {
            id: clearText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            source: (filterEntries.activeFocus || filterEntries.text) ?
                        'image://theme/icon-m-input-clear' :
                        'image://theme/icon-m-common-search'
        }

        MouseArea {
            anchors.fill: clearText
            onClicked: {
                inputContext.reset()
                filterEntries.text = ''
            }
        }
    }

    ListView {
        id: list
        anchors { top: filterEntries.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: entriesModel
        clip: true
        delegate: EntryMenuDelegate {
            title: model.title
            date: model.date
            entryId: model.entryId
            isFavorite: model.isFavorite

            onClicked:{
                list.currentIndex = model.index
                handleAction(model)
            }
        }
        section.property: 'month'
        section.delegate: ListSectionDelegate { sectionName: section }
    }

    ScrollDecorator {
        flickableItem: list
    }

    function handleAction(currentItem) {
        comicView.currentEntry = currentItem
        appWindow.pageStack.push(comicView)
    }
}
