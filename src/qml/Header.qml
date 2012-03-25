import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "constants.js" as UIConstants

Item {
    id: headerItem
    height: appWindow.inPortrait ?
                UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT :
                UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE
    width: parent.width

    property int topMargin: UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE / 2
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

    BorderImage {
        id: background
        anchors.fill: parent
        source: 'image://theme/meegotouch-view-header-fixed'
    }

    Label {
        id: headerTitleText
        platformStyle: LabelStyle {
            fontPixelSize: UIConstants.FONT_SLARGE
        }
        anchors {
            left: parent.left
            leftMargin: UIConstants.DEFAULT_MARGIN
        }
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

    Label {
        id: headerStripDateText
        platformStyle: LabelStyle {
            fontPixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        }
        text: stripDate
        visible: stripDate
    }

    Label {
        id: headerStripNumberText
        platformStyle: LabelStyle {
            fontPixelSize: (appWindow.inPortrait ? UIConstants.FONT_LSMALL : UIConstants.FONT_SLARGE)
        }
        text: title ? '#' + stripNumber : ''
        visible: stripNumber !== -1
    }

    states: [
        State {
            name: 'inLandscape'
            when: !appWindow.inPortrait
            AnchorChanges {
                target: headerTitleText
                anchors.top: undefined
                anchors.verticalCenter: headerTitleText.parent.verticalCenter
            }
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerTitleText.top
                anchors.right: headerStripDateText.parent.right
            }
            AnchorChanges {
                target: headerStripNumberText
                anchors.top: headerTitleText.top
                anchors.right: headerStripDateText.left
            }
            PropertyChanges {
                target: headerStripDateText
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            PropertyChanges {
                target: headerStripNumberText
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
        },
        State {
            name: 'inPortrait'
            when: appWindow.inPortrait && (stripNumber === -1)
            AnchorChanges {
                target: headerTitleText
                anchors.top: undefined
                anchors.verticalCenter: headerTitleText.parent.verticalCenter
            }
        },
        State {
            name: 'inPortraitExtended'
            when: appWindow.inPortrait && (stripNumber !== -1)
            AnchorChanges {
                target: headerTitleText
                anchors.verticalCenter: undefined
                anchors.top: headerTitleText.parent.top
            }
            AnchorChanges {
                target: headerStripNumberText
                anchors.top: headerTitleText.bottom
                anchors.right: headerStripNumberText.parent.right
            }
            AnchorChanges {
                target: headerStripDateText
                anchors.top: headerTitleText.bottom
                anchors.left: headerTitleText.left
            }
            PropertyChanges {
                target: headerTitleText
                anchors.topMargin: UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT / 2
            }
            PropertyChanges {
                target: headerStripNumberText
                anchors.topMargin: UIConstants.PADDING_XSMALL
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            }
            PropertyChanges {
                target: headerStripDateText
                anchors.topMargin: UIConstants.PADDING_XSMALL
            }
        }
    ]
}
