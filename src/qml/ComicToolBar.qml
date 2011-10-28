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
