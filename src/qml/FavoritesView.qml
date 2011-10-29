import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: mainPage

    onStatusChanged: {
        if (status == PageStatus.Active) {
            entriesModel.setFavoritesFiltered(true)
            entriesModel.setFilterWildcard(filterEntries.text)
            favoritesEmpty.visible = list.model.count === 0
        }
    }

    Component.onCompleted: {
        comicView.moveToNext.connect(showNext)
        comicView.moveToPrevious.connect(showPrevious)
        comicView.moveToRandom.connect(showRandom)
    }

    function jumpToLast() {
        list.positionViewAtEnd()
    }

    function jumpToFirst() {
        list.positionViewAtBeginning()
    }

    function showNext() {
        if (isActivePage(mainPage)) {
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
        if (isActivePage(mainPage)) {
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
        if (isActivePage(mainPage)) {
            list.currentIndex = XMCR.getRandomStripNumber(list.model.count)
            list.positionViewAtIndex(list.currentIndex, ListView.Beginning)
            comicView.currentEntry = list.currentItem
            comicView.currentIndex = list.currentIndex
        }
    }

    function handleAction(currentItem) {
        comicView.currentEntry = currentItem
        comicView.currentIndex = currentItem.index
        appWindow.pageStack.push(comicView)
    }

    Header {
        id: topBar
        title: 'Favorites'
    }

    TextField {
        id: filterEntries
        anchors { top: topBar.bottom; left: parent.left; right: parent.right }
        anchors {
            topMargin: UIConstants.DEFAULT_MARGIN
            leftMargin: UIConstants.DEFAULT_MARGIN
            rightMargin: UIConstants.DEFAULT_MARGIN
        }
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
    }

    Item {
        id: favoritesEmpty
        anchors.left: list.left
        anchors.right: list.right
        anchors.verticalCenter: list.verticalCenter
        anchors.margins: UIConstants.DEFAULT_MARGIN

        Text {
            font.pixelSize: UIConstants.FONT_XLARGE
            font.family: UIConstants.FONT_FAMILY
            color: UIConstants.COLOR_FOREGROUND
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
            wrapMode: Text.Wrap
            text: 'Your favorited entries will appear here'
        }
    }

    ScrollDecorator {
        flickableItem: list
    }
}
