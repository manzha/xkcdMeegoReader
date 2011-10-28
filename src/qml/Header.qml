import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "file:///usr/lib/qt4/imports/com/meego/UIConstants.js" as UIConstants

Item {
    id: headerItem
    height: headerRectangle.height
    width: parent.width

    property int topMargin: (appWindow.inPortrait ?
                                UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
                                UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE)
    property string title: ''
    property string stripDate: ''
    property int stripNumber: -1
    property bool isLoading

    function setContent(name, date, number) {
        title = name
        stripDate = date
        stripNumber = number
    }

    function clear() {
        title = ''
        stripDate = ''
        stripNumber = -1
    }

    Rectangle {
        id: headerRectangle
        width: parent.width
        height: appWindow.inPortrait ?
                    UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT :
                    52
        // UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE doesn't seem to be used in the system
        color: 'darkgray'
    }

    Text {
        id: headerTitleText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: UIConstants.FONT_SLARGE
        color: UIConstants.COLOR_FOREGROUND
        anchors { top: parent.top; left: parent.left }
        anchors { topMargin: topMargin; leftMargin: UIConstants.DEFAULT_MARGIN }
        // In portrait mode, we can use all the space minus the margins
        // In landscape, we take the side margins off, then the date and number, and
        // also the margins between them
        width: (appWindow.inPortrait ?
                    parent.width - 2 * UIConstants.DEFAULT_MARGIN :
                    parent.width - headerStripDateText.width - headerStripNumberText.width - 4 * UIConstants.DEFAULT_MARGIN)
        elide: Text.ElideRight
        text: title
        visible: title !== ''
    }

    Text {
        id: headerStripDateText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        color: UIConstants.COLOR_FOREGROUND
        text: stripDate
        visible: stripDate !== undefined
    }

    Text {
        id: headerStripNumberText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        color: UIConstants.COLOR_FOREGROUND
        text: title ? '#' + stripNumber : ''
        visible: stripNumber !== -1
    }

    states: [
        State {
            name: 'inLandscape'
            when: !appWindow.inPortrait
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerTitleText.top
                anchors.right: headerStripDateText.parent.right
            }
            PropertyChanges {
                target: headerStripDateText
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            PropertyChanges {
                target: headerStripNumberText
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            AnchorChanges {
                target: headerStripNumberText
                anchors.top: headerTitleText.top
                anchors.right: headerStripDateText.left
            }
        },
        State {
            name: 'inPortrait'
            when: appWindow.inPortrait
            AnchorChanges {
                target: headerStripNumberText
                anchors.top: headerTitleText.bottom
                anchors.right: headerStripNumberText.parent.right
            }
            PropertyChanges {
                target: headerStripNumberText
                anchors.topMargin: UIConstants.PADDING_XSMALL
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerTitleText.bottom
                anchors.left: headerTitleText.left
            }
            PropertyChanges {
                target: headerStripDateText
                anchors.topMargin: UIConstants.PADDING_XSMALL
            }
        }
    ]
}
