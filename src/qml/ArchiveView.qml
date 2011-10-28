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
        return (tabGroup.currentTab.currentPage == page)
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
        list.positionViewAtEnd()
    }

    function jumpToFirst() {
        list.positionViewAtBeginning()
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
                list.currentIndex < list.model.count - 1) {
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

    function onLoadingFinished() {
        showListHeader = false
    }

    function handleAction(currentItem) {
        comicView.currentEntry = currentItem
        comicView.currentIndex = currentItem.index
        appWindow.pageStack.push(comicView)
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

        onTextChanged: filterTimer.start()

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

        Timer {
            id: filterTimer
            interval: 50
            running: false
            repeat:  false
            onTriggered: entriesModel.setFilterWildcard(filterEntries.text)
        }
    }

    ListView {
        id: list
        anchors { top: filterEntries.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        model: entriesModel
        clip: true
        delegate: EntryMenuDelegate {
            title: model.title
            formattedDate: model.formattedDate
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
            interval: XMCR.REFRESH_TIMEOUT
            onTriggered: {
                if (!fetchingEntries) {
                    onLoadingFinished()
                }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: fetchingEntries && list.model.count === 0
        running: visible
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }

    FastScroll {
        listView: list
    }
}
