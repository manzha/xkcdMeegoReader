import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: window

    Component {
        id: aboutView
        AboutView { }
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem {
                id: aboutEntry
                text: 'About'
                onClicked: {
                    appWindow.pageStack.push(aboutView)
                }
            }
        }
    }
    tools: ToolBarLayout {
        id: commonTools
        ToolIcon {
            iconId: 'icon-m-toolbar-shuffle'
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                if (latestNumber != -1) {
                    var random = XMCR.getRandomStripNumber(latestNumber)
                    fetchContent(XMCR.getUrl(random))
                }
            }
        }
        ToolIcon {
            iconId: 'toolbar-view-menu'
            anchors.right: parent.right
            onClicked: (mainMenu.status == DialogStatus.Closed) ?
                           mainMenu.open() : mainMenu.close()
        }
    }

    Header { id: topBar }

    property int currentNum: -1
    property int latestNumber: -1
    property bool showAlt: false
    property bool showControls: false
    property bool isLoading: false

    Component.onCompleted: {
        fetchContent(XMCR.URL)
    }

    ZoomableImage {
        id: flickable
        onImageReady: {
            isLoading = false
        }
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
            iconId: 'icon-m-toolbar-mediacontrol-previous'
            enabled: currentNum != 1
            onClicked: fetchContent(XMCR.getUrl(1))
            anchors.left: parent.left
        }

        ToolIcon {
            id: previousStrip
            iconId: 'icon-m-toolbar-previous'
            enabled: currentNum != 1
            onClicked: fetchContent(XMCR.getUrl(currentNum - 1))
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
            iconId: 'icon-m-toolbar-next'
            onClicked: fetchContent(XMCR.getUrl(currentNum + 1))
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
        asyncWorker.sendMessage({ url: contentUrl })
    }

    function parseResponse(response) {
        if (response) {
            var stripEntry = JSON.parse(response)
//            listModel.append({
//                'link': a['link'],
//                'news': a['news'],
//                'safe_title': a['safe_title'],
//                'transcript': a['transcript'],
            flickable.source = stripEntry['img']
            currentNum = parseInt(stripEntry['num'])
            if (latestNumber < currentNum) latestNumber = currentNum
            altTextBanner.text = stripEntry['alt']

            topBar.setContent(stripEntry['title'],
                              new Date(stripEntry['year'], stripEntry['month'], stripEntry['day']),
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
