import QtQuick 1.1
import com.nokia.meego 1.0
import "XMCR.js" as XMCR

ToolBarLayout {
    ToolIcon {
        iconId: 'toolbar-back'
        onClicked: appWindow.pageStack.pop()
    }
    ToolIcon {
        iconId: 'icon-m-toolbar-shuffle'
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: window.moveToRandom()
    }
    ToolIcon {
        id: favoriteIcon
        iconId: (currentEntry && currentEntry.isFavorite ?
                     'toolbar-favorite-mark' :
                     'toolbar-favorite-unmark')
        onClicked: {
            if (currentEntry) {
                // It seems that editing a model is not supported yet,
                // so we need to do it manually
                entriesModel.updateFavorite(currentIndex, !currentEntry.isFavorite)
            }
        }
    }
    ToolIcon {
        id: shareIcon
        iconId: 'toolbar-share'
        onClicked: controller.share(currentEntry.title, XMCR.getUrl(currentEntry.entryId))
    }
}
