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
        onHeightChanged: image.calculateSize()
        visible: image.status == Image.Ready

        // Zoom features support (both pinch gesture and double click) taken from
        // http://projects.developer.nokia.com/QuickFlickr/browser/qml/ZoomableImage.qml

        Item {
            id: imageContainer
            width: Math.max(image.width * image.scale, flickable.width)
            height: Math.max(image.height * image.scale, flickable.height)

            Image {
                id: image
                property real prevScale
                smooth: !flickable.movingVertically
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit

                function calculateSize() {
                    scale = Math.min(flickable.width / width, flickable.height / height) * 0.98;
                    pinchArea.minScale = scale;
                    prevScale = Math.min(scale, 1);
                }

                onScaleChanged: {
                    if ((width * scale) > flickable.width) {
                        var xoff = (flickable.width / 2 + flickable.contentX) * scale / prevScale;
                        flickable.contentX = xoff - flickable.width / 2;
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (flickable.height / 2 + flickable.contentY) * scale / prevScale;
                        flickable.contentY = yoff - flickable.height / 2;
                    }

                    prevScale = scale;
                }

                onStatusChanged: {
                    if (status == Image.Ready) {
                        calculateSize();
                    }
                }
            }
        }

        PinchArea {
            id: pinchArea
            property real minScale:  1.0
            property real lastScale: 1.0
            anchors.fill: parent

            pinch.target: image
            pinch.minimumScale: minScale
            pinch.maximumScale: 3.0

            onPinchFinished: flickable.returnToBounds()
        }

        MouseArea {
            anchors.fill : parent
            property bool doubleClicked: false

            Timer {
                id: clickTimer
                interval: 350
                running: false
                repeat:  false
                onTriggered: showControls = !showControls
            }

            onDoubleClicked: {
                clickTimer.stop();
                mouse.accepted = true;

                if (image.scale > pinchArea.minScale) {
                    image.scale = pinchArea.minScale;
                    flickable.returnToBounds();
                } else {
                    image.scale = 2.3;
                }
            }

            onClicked: {
                // There's a bug in Qt Components emitting a clicked signal
                // when a double click is done.
                clickTimer.start()
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
        visible: image.status == Image.Loading
        running: visible
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    function fetchContent(contentUrl) {
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
}
