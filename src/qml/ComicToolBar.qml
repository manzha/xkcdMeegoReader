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

ToolBarLayout {
    property variant activeItem
    property bool saveDisabled: true
    signal goToRandom()
    signal toggleFavorite()
    signal shareContent()

    ToolIcon {
        iconId: 'toolbar-back'
        onClicked: pageStack.pop()
    }
    ToolIcon {
        iconId: 'icon-m-toolbar-shuffle'
        onClicked: goToRandom()
    }
    ToolIcon {
        id: favoriteIcon
        enabled: !saveDisabled
        iconId: (activeItem && activeItem.isFavorite ?
                     'icon-m-toolbar-favorite-mark' :
                     'icon-m-toolbar-favorite-unmark') +
                (saveDisabled ? '-dimmed' : '')
        onClicked: toggleFavorite()
    }
    ToolIcon {
        id: shareIcon
        iconId: 'toolbar-share'
        onClicked: shareContent()
    }
}
