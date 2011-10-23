import QtQuick 1.1
import com.nokia.meego 1.0

ToolBarLayout {
    property variant activeItem
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
        iconId: (activeItem && activeItem.isFavorite ?
                     'toolbar-favorite-mark' :
                     'toolbar-favorite-unmark')
        onClicked: toggleFavorite()
    }
    ToolIcon {
        id: shareIcon
        iconId: 'toolbar-share'
        onClicked: shareContent()
    }
}
