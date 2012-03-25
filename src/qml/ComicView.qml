import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import 'constants.js' as UIConstants
import "XMCR.js" as XMCR

Page {
    id: window

    tools: comicTools

    ComicToolBar {
        id: comicTools
        activeItem: currentEntry
        saveDisabled: isLoading
        onToggleFavorite: {
            if (activeItem) {
                // It seems that editing a model is not supported yet,
                // so we need to do it manually
                var favorite = !currentEntry.isFavorite
                entriesModel.updateFavorite(currentIndex, favorite)
                if (favorite) {
                    flickable.save()
                }
            }
        }
        onGoToRandom: window.moveToRandom()
        onShareContent: controller.share(currentEntry.title, XMCR.getUrl(currentEntry.entryId))
    }

    Rectangle {
        anchors.fill: parent
        color: 'white'
    }

    Header { id: topBar }

    property bool showAlt: false
    property bool isLoading: flickable.status == Image.Loading ||
                             (currentEntry && !currentEntry.imageSource)

    property variant currentEntry: ''
    property int currentIndex: -1

    signal moveToPrevious()
    signal moveToNext()
    signal moveToRandom()

    onStatusChanged: {
        if (status === PageStatus.Active && currentEntry) {
            fetchContent()
        }
    }

    onCurrentEntryChanged: {
        if (status === PageStatus.Active && currentEntry) {
            fetchContent()
        }
    }

    ZoomableImage {
        id: flickable
        remoteSource: currentEntry ? currentEntry.imageSource : ''
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

    ProgressBar {
        id: busyIndicator
        anchors.centerIn: parent
        width: parent.width / 2
        minimumValue: 0
        maximumValue: 1
        value: flickable.progress
        visible: isLoading
        indeterminate: (currentEntry && !currentEntry.imageSource)
    }

    function fetchContent() {
        topBar.clear()
        showAlt = false
        topBar.setContent(currentEntry.title,
                          currentEntry.formattedDate,
                          currentEntry.entryId)
        if (!currentEntry.altText || !currentEntry.imageSource) {
            asyncWorker.sendMessage({ url: XMCR.getAPIUrl(currentEntry.entryId) })
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
