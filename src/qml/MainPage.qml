import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants
import "XMCR.js" as XMCR

Page {
    id: window
    SelectionDialog {
        id: zoomSelectionDialog
        titleText: 'Zoom type'
        selectedIndex: 0

        model: ListModel {
            ListElement { name: 'Fit all' }
            ListElement { name: 'Actual size' }
        }
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem {
                id: aboutEntry
                text: 'About'
            }
            MenuItem {
                id: zoomEntry
                text: 'Zoom level'
                Image {
                    source: 'image://theme/icon-m-common-combobox-arrow'
                    anchors.right: parent.right
                    anchors.rightMargin: UIConstants.DEFAULT_MARGIN
                    anchors.verticalCenter: parent.verticalCenter
                }
                onClicked: {
                    zoomSelectionDialog.open()
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
                    var random = Math.ceil(Math.random() * latestNumber) + 1
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
    property int zoomType: (zoomSelectionDialog.selectedIndex === 0 ?
                                XMCR.ZOOM_FIT_ALL :
                                XMCR.ZOOM_ACTUAL_SIZE)

    Component.onCompleted: {
        fetchContent(XMCR.URL)
    }

    Rectangle {
        anchors.fill: flickable
        color: 'darkgrey'
    }

    Flickable {
        id: flickable
        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        contentHeight: imageContainer.height
        contentWidth: imageContainer.width
        visible: image.status == Image.Ready

        Item {
            id: imageContainer
            width: zoomType == XMCR.ZOOM_FIT_ALL ?
                        flickable.width :
                        Math.max(flickable.width, image.implicitWidth)
            height: zoomType == XMCR.ZOOM_FIT_ALL ?
                        flickable.height :
                        Math.max(flickable.height, image.implicitHeight)
            Image {
                id: image
                anchors.centerIn: parent
                width: Math.min(parent.width, implicitWidth)
                height: Math.min(parent.height, implicitHeight)
                fillMode: Image.PreserveAspectFit
                smooth: true
                onStatusChanged: {
                    if (status == Image.Ready) {
                        window.state = 'Ready'
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                showControls = !showControls
            }
        }
    }

    Rectangle {
        id: altTextBanner
        color: 'white'
        opacity: showAlt ? 0.75 : 0
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
        visible: false
        running: visible
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    function fetchContent(contentUrl) {
        window.state = 'Loading'
        asyncWorker.sendMessage({ url: contentUrl })
    }

    function parseResponse(response) {
        if (response) {
            var stripEntry = JSON.parse(response);
//            listModel.append({
//                'link': a['link'],
//                'news': a['news'],
//                'safe_title': a['safe_title'],
//                'transcript': a['transcript'],
            image.source = stripEntry['img']
            currentNum = parseInt(stripEntry['num'])
            topBar.stripName = stripEntry['title']
            topBar.stripNumber = currentNum
            if (latestNumber < currentNum) latestNumber = currentNum
            topBar.stripDate = new Date(stripEntry['year'], stripEntry['month'], stripEntry['day'])
            altTextBanner.text = stripEntry['alt']
        }
    }

    WorkerScript {
        id: asyncWorker
        source: 'workerscript.js'

        onMessage: {
            parseResponse(messageObject.response)
        }
    }

    states: [
        State {
            name: 'Loading'
            PropertyChanges {
                target: busyIndicator; visible: true
            }
        },
        State {
            name: 'Ready'
            PropertyChanges {
                target: busyIndicator; visible: false
            }
        }
    ]
}
