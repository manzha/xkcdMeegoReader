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
    property string stripName: ''
    property variant stripDate
    property int stripNumber

    Rectangle {
        id: headerRectangle
        width: parent.width
        height: appWindow.inPortrait ?
                    UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT :
                    52
        // UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE doesn't seem to be used in the system
        color: 'white'
    }

    Text {
        id: headerStripNameText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: UIConstants.FONT_SLARGE
        color: UIConstants.COLOR_FOREGROUND
        anchors { top: parent.top; left: parent.left }
        anchors { topMargin: topMargin; leftMargin: UIConstants.DEFAULT_MARGIN }
        text: stripName
    }

    Text {
        id: headerStripDateText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        color: UIConstants.COLOR_SECONDARY_FOREGROUND
        text: Qt.formatDate(stripDate, Qt.DefaultLocaleShortDate)
    }

    Text {
        id: headerStripNumberText
        font.family: UIConstants.FONT_FAMILY
        font.pixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        color: UIConstants.COLOR_SECONDARY_FOREGROUND
        text: stripName ? '#' + stripNumber : ''
    }

    states: [
        State {
            name: "inLandscape"
            when: !appWindow.inPortrait
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerStripNameText.top
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
                anchors.top: headerStripNameText.top
                anchors.right: headerStripDateText.left
            }
        },
        State {
            name: "inPortrait"
            when: appWindow.inPortrait
            AnchorChanges {
                target: headerStripNumberText
                anchors.top: headerStripNameText.bottom
                anchors.right: headerStripNumberText.parent.right
            }
            PropertyChanges {
                target: headerStripNumberText
                anchors.topMargin: UIConstants.PADDING_XSMALL
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerStripNameText.bottom
                anchors.left: headerStripNameText.left
            }
            PropertyChanges {
                target: headerStripDateText
                anchors.topMargin: UIConstants.PADDING_XSMALL
            }
        }
    ]
}
