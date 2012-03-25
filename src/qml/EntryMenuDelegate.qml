/**************************************************************************
 *   XMCR
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
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
import com.nokia.extras 1.1
import 'constants.js' as UIConstants

Item {
    id: entryMenuDelegate

    signal clicked

    property alias title: entryTitleText.text
    property int entryId: 0
    property bool isFavorite: false
    property string altText
    property string formattedDate
    property string imageSource

    width: parent.width
    height: UIConstants.LIST_ITEM_HEIGHT

    BorderImage {
        anchors.fill: parent
        visible: mouseArea.pressed
        source: 'image://theme/meegotouch-list-fullwidth-background-pressed-vertical-center'
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: entryMenuDelegate.clicked()
    }

    Item {
        anchors {
            fill: parent
            leftMargin: UIConstants.DEFAULT_MARGIN
            rightMargin: UIConstants.DEFAULT_MARGIN
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 2 * UIConstants.LIST_ITEM_SPACING - favoriteIcon.width - entryIdText.width

            Label {
                id: entryTitleText
                platformStyle: LabelStyle {
                    fontPixelSize: UIConstants.FONT_SLARGE
                }
                width: parent.width
                elide: Text.ElideRight
            }

            Label {
                id: entryDateText
                platformStyle: LabelStyle {
                    fontFamily: "Nokia Pure Text Light"
                    fontPixelSize: UIConstants.FONT_LSMALL
                }
                color: UIConstants.LIST_SUBTITLE_COLOR
                text: formattedDate
            }
        }

        Image {
            id: favoriteIcon
            anchors {
                right: entryIdText.left
                rightMargin: UIConstants.LIST_ITEM_SPACING
                verticalCenter: parent.verticalCenter
            }
            source: 'image://theme/icon-s-common-favorite-mark'
            visible: isFavorite
        }

        Label {
            id: entryIdText
            platformStyle: LabelStyle {
                fontFamily: "Nokia Pure Text Light"
                fontPixelSize: UIConstants.FONT_LSMALL
            }
            color: UIConstants.LIST_SUBTITLE_COLOR
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            text: '#' + entryId
        }
    }
}
