/**************************************************************************
 *    XMCR
 *    Copyright (C) 2011 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import 'constants.js' as UIConstants

Item {
    id: refreshHeader
    height: showHeader ?
                headerHeight :
                0
    width: parent.width
    x: UIConstants.DEFAULT_MARGIN
    y: yPosition < 0 ?
        -height :
        -yPosition - height
    opacity: showHeader ? 1 : 0

    Behavior on height {
        NumberAnimation { from: headerHeight; duration: 200 }
    }

    signal clicked
    property bool loading: false
    property real yPosition
    property bool showHeader: false
    property real headerHeight: (appWindow.inPortrait ?
                                     UIConstants.LIST_ITEM_HEIGHT_DEFAULT :
                                     UIConstants.LIST_ITEM_HEIGHT_SMALL)
    property variant lastUpdate

    BorderImage {
        id: background
        anchors.fill: parent
        anchors.leftMargin: -UIConstants.DEFAULT_MARGIN
        anchors.rightMargin: -UIConstants.DEFAULT_MARGIN
        visible: refreshHeaderMouseArea.pressed
        source: 'image://theme/meegotouch-list-background-pressed-vertical-center'
    }

    Item {
        id: refreshHeaderImage
        anchors.verticalCenter: parent.verticalCenter
        width: refreshHeaderIcon.width
        height: refreshHeaderIcon.height

        Image {
            id: refreshHeaderIcon
            source: 'image://theme/icon-m-toolbar-refresh-dimmed'
            visible: !loading
        }

        BusyIndicator {
            visible: loading
            running: loading
            anchors.centerIn: parent
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }
    }

    Column {
        anchors.verticalCenter: refreshHeaderImage.verticalCenter
        anchors.left: refreshHeaderImage.right
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN

        Text {
            id: refreshHeaderText
            font.pixelSize: UIConstants.FONT_LARGE
            font.family: "Nokia Pure Text Light"
            color: UIConstants.COLOR_BUTTON_DISABLED_FOREGROUND
            text: loading ? qsTr('Updating') : qsTr('Tap to update')
        }

        Text {
            id: refreshHeaderLastUpdate
            font.pixelSize: UIConstants.FONT_XXSMALL
            font.family: "Nokia Pure Text Light"
            color: UIConstants.COLOR_BUTTON_DISABLED_FOREGROUND
            // TODO: figure out how to provide translatable date while
            // keeping the binding
            text: qsTr('Last update: ') + Qt.formatDateTime(lastUpdate)
        }
    }

    MouseArea {
        id: refreshHeaderMouseArea
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
    }
}
