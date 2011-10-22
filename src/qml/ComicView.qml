import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: window

    tools: comicTools

    ComicToolBar { id: comicTools }

    Rectangle {
        anchors.fill: parent
        color: 'darkgrey'
    }

    Header { id: topBar }

    property bool showAlt: false
    property bool isLoading: flickable.status == Image.Loading

    property variant currentEntry
    property int currentIndex: -1

    signal moveToPrevious()
    signal moveToNext()
    signal moveToRandom()

    onStatusChanged: {
        if (status == PageStatus.Active && currentEntry) {
            fetchContent(XMCR.getUrl(currentEntry.entryId))
        }
    }

    onCurrentEntryChanged: {
        if (status == PageStatus.Active && currentEntry) {
            fetchContent(XMCR.getUrl(currentEntry.entryId))
        }
    }

    ZoomableImage {
        id: flickable
        source: currentEntry ? currentEntry.imageSource : ''
        visible: !isLoading
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onSwipeLeft: window.moveToPrevious()
        onSwipeRight: window.moveToNext()
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    Rectangle {
        id: altTextBanner
        color: 'white'
        opacity: showAlt ? 0.85 : 0
        anchors.fill: flickable

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Text {
            id: altTextBannerText
            anchors.fill: parent
            anchors.margins: UIConstants.DEFAULT_MARGIN
            font.family: UIConstants.FONT_FAMILY
            font.pixelSize: UIConstants.FONT_SLARGE
            wrapMode: Text.Wrap
            color: UIConstants.COLOR_FOREGROUND
            text: currentEntry ? currentEntry.altText : ''
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: isLoading
        running: visible
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }

    function fetchContent(contentUrl) {
        topBar.clear()
        showAlt = false
        topBar.setContent(currentEntry.title,
                          currentEntry.date,
                          currentEntry.entryId)
        if (!currentEntry.altText || !currentEntry.imageSource) {
            asyncWorker.sendMessage({ url: contentUrl })
        }
    }

    function parseResponse(response) {
        if (response) {
            var stripEntry = JSON.parse(response)

            if (!currentEntry.imageSource) {
                entriesModel.updateImageSource(currentIndex, stripEntry['img'])
            }

            if (!currentEntry.altText) {
                entriesModel.updateAltText(currentIndex, stripEntry['alt'])
            }
        }
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            parseResponse(messageObject.response)
        }
    }
}
