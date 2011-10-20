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

    Rectangle {
        id: extraTools
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: UIConstants.LIST_ITEM_HEIGHT_SMALL
        color: 'white'
        opacity: showControls ? 0.75 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        ToolIcon {
            id: firstStrip
            iconId: enabled ? 'icon-m-toolbar-mediacontrol-previous' : 'icon-m-toolbar-mediacontrol-previous-dimmed'
            enabled: currentNum != 1
            onClicked: fetchContent(XMCR.getUrl(1))
            anchors.left: parent.left
        }

        ToolIcon {
            id: previousStrip
            iconId: enabled ? 'icon-m-toolbar-previous' : 'icon-m-toolbar-previous-dimmed'
            enabled: currentNum != 1
            onClicked: window.moveToPrevious()
            anchors.left: firstStrip.right
            anchors.leftMargin: (alternateText.x - firstStrip.x) / 2 - firstStrip.width
        }

        ToolIcon {
            id: alternateText
            iconId: 'icon-m-invitation-pending'
            onClicked: {
                showAlt = !showAlt
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ToolIcon {
            id: nextStrip
            iconId: enabled ? 'icon-m-toolbar-next' : 'icon-m-toolbar-next-dimmed'
            enabled: currentNum != latestNumber
            onClicked: window.moveToNext()
            anchors.right: lastStrip.left
            anchors.rightMargin: (alternateText.x - firstStrip.x) / 2 - firstStrip.width
        }

        ToolIcon {
            id: lastStrip
            iconId: 'icon-m-toolbar-mediacontrol-next'
            onClicked: fetchContent(XMCR.URL)
            anchors.right: parent.right
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
