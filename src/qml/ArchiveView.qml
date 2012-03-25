import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as UIConstants
import 'XMCR.js' as Util

Page {
    id: archivePage

    property bool storesFavorites: false
    property real contentYPos: list.visibleArea.yPosition *
                               Math.max(list.height, list.contentHeight)
    property bool showListHeader: false
    property bool fetchingEntries: false
    property variant archiveLastUpdate: controller.lastUpdateDate()

    function isActivePage(page) {
        return (tabGroup.currentTab.currentPage === page)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            entriesModel.setFavoritesFiltered(storesFavorites)
            entriesModel.setFilterWildcard(filterEntries.text)
            favoritesEmpty.visible = storesFavorites &&
                    list.model.count === 0
            if (!filterEntries.text &&
                    list.model.count === 0 &&
                    !storesFavorites) {
                controller.fetchEntries()
                fetchingEntries = true
            }
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
        archiveLastUpdate = controller.lastUpdateDate()
    }

    function jumpToLast() {
        list.positionViewAtEnd()
    }

    function jumpToFirst() {
        list.positionViewAtBeginning()
    }

    function showNext() {
        if (isActivePage(archivePage)) {
            if (list.currentIndex > 0) {
                list.currentIndex --
            } else {
                list.currentIndex = list.model.count - 1
            }
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    function showPrevious() {
        if (isActivePage(archivePage)) {
            if (list.currentIndex < list.model.count - 1) {
                list.currentIndex ++
            } else {
                list.currentIndex = 0
            }
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    function showRandom() {
        if (isActivePage(archivePage)) {
            list.currentIndex = Util.getRandomStripNumber(list.model.count)
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
        title: storesFavorites ? qsTr('Favorites') : qsTr('Archive')
    }

    TextField {
        id: filterEntries
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            topMargin: UIConstants.DEFAULT_MARGIN
            leftMargin: UIConstants.DEFAULT_MARGIN
            rightMargin: UIConstants.DEFAULT_MARGIN
        }
        placeholderText: qsTr('Search')
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
        anchors {
            top: filterEntries.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
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
            showHeader: !storesFavorites && showListHeader
            loading: fetchingEntries
            yPosition: contentYPos
            lastUpdate: archiveLastUpdate

            onClicked: {
                controller.fetchEntries()
                fetchingEntries = true
            }
        }

        Connections {
            target: list.visibleArea
            onYPositionChanged: {
                if ((!list.flicking && list.moving) &&
                        contentYPos < 0 &&
                        !showListHeader) {
                    showListHeader = true
                    listTimer.start()
                }
            }
        }

        Timer {
            id: listTimer
            interval: Util.REFRESH_TIMEOUT
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

    Label {
        id: favoritesEmpty
        platformStyle: LabelStyle {
            fontPixelSize: UIConstants.FONT_XLARGE
        }
        color: UIConstants.COLOR_FOREGROUND
        width: parent.width - UIConstants.DEFAULT_MARGIN * 2
        anchors.centerIn: parent
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        opacity: 0.5
        text: qsTr('Your favorited entries will appear here')
        horizontalAlignment: Text.AlignHCenter
    }

    FastScroll {
        listView: list
        visible: !storesFavorites
        enabled: visible
    }

    ScrollDecorator {
        flickableItem: list
        visible: storesFavorites
        enabled: visible
    }
}
