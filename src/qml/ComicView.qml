import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: window

    tools: ToolBarLayout {
        ToolIcon {
            iconId: 'toolbar-back'
            onClicked: appWindow.pageStack.pop()
        }
        ToolIcon {
            iconId: 'icon-m-toolbar-shuffle'
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: window.moveToRandom()
        }
        ToolIcon {
            id: favoriteIcon
            iconId: (currentEntry && currentEntry.isFavorite ?
                         'toolbar-favorite-mark' :
                         'toolbar-favorite-unmark')
            onClicked: {
                if (currentEntry) {
                    // It seems that editing a model is not supported yet,
                    // so we need to do it manually
                    entriesModel.updateFavorite(currentIndex, !currentEntry.isFavorite)
                }
            }
        }
        ToolIcon {
            id: shareIcon
            iconId: 'toolbar-share'
            onClicked: controller.share(currentEntry.title, XMCR.getUrl(currentEntry.entryId))
        }
    }

    Rectangle {
        anchors.fill: parent
        color: 'darkgrey'
    }

    Header { id: topBar }

    property bool showAlt: false
    property bool isLoading: false

    property variant currentEntry
    property int currentIndex: -1

    signal moveToPrevious()
    signal moveToNext()
    signal moveToRandom()

    onStatusChanged: {
        if (status == PageStatus.Active && currentEntry) {
            fetchContent(XMCR.getUrl(currentEntry.entryId))
        } else if (status == PageStatus.Inactive) {
            flickable.source = ''
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
        onImageReady: {
            isLoading = false
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
        isLoading = true
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
