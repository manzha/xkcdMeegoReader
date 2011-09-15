import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants

Page {
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        id: commonTools

        ToolIcon {
            iconId: 'icon-m-toolbar-mediacontrol-previous'
            enabled: currentNum != 1
            onClicked: fetchContent(getUrl(1))
        }
        ToolIcon {
            iconId: 'icon-m-toolbar-previous'
            enabled: currentNum != 1
            onClicked: fetchContent(getUrl(currentNum - 1))
        }
        ToolIcon {
            iconId: 'icon-m-content-description'
            onClicked: {
                if (showAlt) {
                    transcriptBanner.hide()
                } else {
                    transcriptBanner.show()
                }
                showAlt = !showAlt
            }
        }
        ToolIcon {
            iconId: 'icon-m-toolbar-next'
            onClicked: fetchContent(getUrl(currentNum + 1))
        }
        ToolIcon {
            iconId: 'icon-m-toolbar-mediacontrol-next'
            onClicked: fetchContent(xkcdUrl)
        }
    }

    Item {
        id: topBar
        anchors { left: parent.left; top: parent.top; right: parent.right }
        height: UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT

        Rectangle {
            anchors.fill: parent
            color: 'white'
            opacity: 0.75
        }

        Text {
            id: titleText
            font.pixelSize: UIConstants.FONT_SLARGE
            color: UIConstants.COLOR_FOREGROUND
            anchors { top: parent.top; left: parent.left }
            anchors.topMargin: 15
            anchors.leftMargin: 16
        }
        Text {
            id: dateText
            font.pixelSize: UIConstants.FONT_LSMALL
            color: UIConstants.COLOR_SECONDARY_FOREGROUND
            anchors { top: titleText.bottom; left: parent.left }
            anchors.topMargin: 2
            anchors.leftMargin: 16
        }
        Text {
            id: numberText
            font.pixelSize: UIConstants.FONT_LSMALL
            color: UIConstants.COLOR_SECONDARY_FOREGROUND
            anchors { top: titleText.bottom; right: parent.right }
            anchors.topMargin: 2
            anchors.rightMargin: 16
        }
    }

    InfoBanner {
        id: transcriptBanner
        timerEnabled: false
        topMargin: UIConstants.DEFAULT_MARGIN
        leftMargin: UIConstants.DEFAULT_MARGIN
    }

    function getUrl(num) {
        return 'http://xkcd.com/' + num + '/info.0.json'
    }

    property string xkcdUrl: 'http://xkcd.com/info.0.json'
    property int currentNum: -1
    property bool showAlt: false

    BusyIndicator {
        id: busyIndicator
        visible: image.status != Image.Ready
        running: image.status != Image.Ready
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        contentHeight: imageContainer.height
        contentWidth: imageContainer.width

        Item {
            id: imageContainer

            width: Math.max(image.width * image.scale, flickable.width)
            height: Math.max(image.height * image.scale, flickable.height)

            Image {
                id: image

                property real previousScale

                anchors.centerIn: parent

                onScaleChanged: {
                    if ((width * scale) > flickable.width) {
                        var xoff = (flickable.width / 2 + flickable.contentX) * scale / previousScale
                        flickable.contentX = xoff - flickable.width / 2
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (flickable.height / 2 + flickable.contentY) * scale / previousScale
                        flickable.contentY = yoff - flickable.height / 2
                    }
                    previousScale = scale
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onDoubleClicked: {
                image.scale = image.scale > 1 ? 1 : image.scale * 2
            }
        }
    }

    ScrollDecorator {
        flickableItem: flickable
    }

    Component.onCompleted: {
        fetchContent(xkcdUrl)
    }

    function fetchContent(contentUrl) {
        myWorker.sendMessage({ url: contentUrl })
    }

    WorkerScript {
        id: myWorker
        source: 'workerscript.js'

        onMessage: {
            parseResponse(messageObject.response)
        }
    }

    function parseResponse(response) {
        if (response) {
            var a = JSON.parse(response);
//            listModel.append({
//                'img': a['img'],
//                'title': a['title'],
//                'month': a['month'],
//                'num': a['num'],
//                'link': a['link'],
//                'year': a['year'],
//                'news': a['news'],
//                'safe_title': a['news'],
//                'transcript': a['transcript'],
//                'alt': a['alt'],
//                'day': a['day']})
            image.source = a['img']
            currentNum = parseInt(a['num'])
            titleText.text = a['title']
            numberText.text = currentNum
            dateText.text = a['day'] + '-' + a['month'] + '-' + a['year']
            transcriptBanner.text = a['alt']
        }
    }
}
