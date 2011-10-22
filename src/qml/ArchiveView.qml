import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: mainPage

    property bool filterFavorites: false
    property real contentYPos: list.visibleArea.yPosition *
                               Math.max(list.height, list.contentHeight)
    property bool showListHeader: false
    property bool fetchingEntries: false

    function isActivePage(page) {
        return tabGroup.currentTab.find(
                    function(page) {
                        return page == mainPage
                        })
    }

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
        commonTools.jumpToFirstEntry.connect(jumpToFirst)
        commonTools.jumpToLastEntry.connect(jumpToLast)
    }

    Connections {
        target: controller
        onEntriesFetched: handleEntriesFetched(ok)
    }

    function handleEntriesFetched(ok) {
        fetchingEntries = false
        onLoadingFinished()
    }

    function jumpToLast() {
        if (isActivePage(mainPage)) {
            list.positionViewAtEnd()
        }
    }

    function jumpToFirst() {
        if (isActivePage(mainPage)) {
            list.positionViewAtBeginning()
        }
    }

    function showNext() {
        if (isActivePage(mainPage) &&
                list.currentIndex > 0) {
            list.currentIndex --
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    function showPrevious() {
        if (isActivePage(mainPage) &&
                list.currentIndex < list.model.count) {
            list.currentIndex ++
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    function showRandom() {
        if (isActivePage(mainPage)) {
            list.currentIndex = XMCR.getRandomStripNumber(list.model.count + 1)
            list.positionViewAtIndex(list.currentIndex, ListView.Beginning)
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    Header {
        id: topBar
        title: 'Archive'
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
            altText: model.altText
            imageSource: model.imageSource

            onClicked:{
                list.currentIndex = model.index
                handleAction(model)
            }
        }
        section.property: 'month'
        section.delegate: ListSectionDelegate { sectionName: section }
        header: RefreshHeader {
            id: refreshHeader
            showHeader: showListHeader
            loading: fetchingEntries
            yPosition: contentYPos

            onClicked: {
                controller.fetchEntries()
                fetchingEntries = true
            }
        }

        Connections {
            target: list.visibleArea
            onYPositionChanged: {
                if (contentYPos < 0 &&
                        !showListHeader &&
                        (list.moving && !list.flicking)) {
                    showListHeader = true
                    listTimer.start()
                }
            }
        }

        Timer {
            id: listTimer
            interval: 3000
            onTriggered: {
                if (!fetchingEntries) {
                    onLoadingFinished()
                }
            }
        }
    }

    ScrollDecorator {
        flickableItem: list
    }

    function onLoadingFinished() {
        showListHeader = false
    }

    function handleAction(currentItem) {
        comicView.currentEntry = currentItem
        comicView.currentIndex = currentItem.index
        appWindow.pageStack.push(comicView)
    }
}
