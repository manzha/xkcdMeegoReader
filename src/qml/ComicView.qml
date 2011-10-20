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
    }

    Rectangle {
        anchors.fill: parent
        color: 'darkgrey'
    }

    Header { id: topBar }

    property int currentNum: -1
    property int latestNumber: -1
    property bool showAlt: false
    property bool showControls: false
    property bool isLoading: false

    property variant currentEntry

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

        property alias text: altTextBannerText.text

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
        flickable.source = ''
        showAlt = false
        altTextBannerText.text = ''
        asyncWorker.sendMessage({ url: contentUrl })
        topBar.setContent(currentEntry.title,
                          currentEntry.date,
                          currentEntry.entryId)
    }

    function parseResponse(response) {
        if (response) {
            var stripEntry = JSON.parse(response)
            flickable.source = stripEntry['img']
            currentNum = parseInt(stripEntry['num'])
            if (latestNumber < currentNum) latestNumber = currentNum
            altTextBanner.text = stripEntry['alt']
            topBar.setContent(stripEntry['title'],
                              new Date(stripEntry['year'], stripEntry['month'] - 1, stripEntry['day']),
                              currentNum)
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
