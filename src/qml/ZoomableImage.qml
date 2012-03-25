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

// Zoom features support (both pinch gesture and double click) taken from
// http://projects.developer.nokia.com/QuickFlickr/browser/qml/ZoomableImage.qml

Flickable {
    id: flickable
    clip: true
    contentHeight: imageContainer.height
    contentWidth: imageContainer.width
    onHeightChanged: image.calculateSize()

    property alias source: image.source
    property alias status: image.status
    property alias progress: image.progress
    property string remoteSource: ''
    property string localSource: ''
    signal swipeLeft()
    signal swipeRight()

    function save() {
        controller.saveImage(image, remoteSource)
    }

    onRemoteSourceChanged: {
        localSource = controller.localSource(remoteSource)
        if (localSource) {
            image.source = localSource
            image.calculateSize()
        } else {
            image.source = remoteSource
        }
    }

    Item {
        id: imageContainer
        width: Math.max(image.width * image.scale, flickable.width)
        height: Math.max(image.height * image.scale, flickable.height)

        AnimatedImage {
            id: image
            property real prevScale
            smooth: !flickable.movingVertically
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit

            function calculateSize() {
                scale = Math.min(flickable.width / width, flickable.height / height) * 0.98;
                pinchArea.minScale = scale;
                prevScale = Math.min(scale, 1);
            }

            onScaleChanged: {
                if ((width * scale) > flickable.width) {
                    var xoff = (flickable.width / 2 + flickable.contentX) * scale / prevScale;
                    flickable.contentX = xoff - flickable.width / 2;
                }
                if ((height * scale) > flickable.height) {
                    var yoff = (flickable.height / 2 + flickable.contentY) * scale / prevScale;
                    flickable.contentY = yoff - flickable.height / 2;
                }

                prevScale = scale;
            }

            onStatusChanged: {
                if (status == Image.Ready) {
                    calculateSize();
                    playing = true
                } else if (status == Image.Error &&
                           image.source != remoteSource) {
                    image.source = remoteSource
                }
            }
        }
    }

    PinchArea {
        id: pinchArea
        property real minScale:  1.0
        property real lastScale: 1.0
        anchors.fill: parent

        pinch.target: image
        pinch.minimumScale: minScale
        pinch.maximumScale: 3.0

        onPinchFinished: flickable.returnToBounds()
    }

    MouseArea {
        anchors.fill : parent
        property bool doubleClicked: false
        property bool swipeDone: false
        property int startX
        property int startY
        property real startScale: pinchArea.minScale

        Timer {
            id: clickTimer
            interval: 350
            running: false
            repeat:  false
            onTriggered: {
                if (!parent.swipeDone) {
                    showAlt = !showAlt
                }
                parent.swipeDone = false
            }
        }

        onDoubleClicked: {
            clickTimer.stop()
            mouse.accepted = true

            if (image.scale > pinchArea.minScale) {
                image.scale = pinchArea.minScale
                flickable.returnToBounds()
            } else {
                image.scale = 2.3
            }
        }

        onClicked: {
            // There's a bug in Qt Components emitting a clicked signal
            // when a double click is done.
            clickTimer.start()
        }

        onPressed: {
            startX = (mouse.x / image.scale)
            startY = (mouse.y / image.scale)
            startScale = image.scale
        }

        onReleased: {
            if (image.scale === startScale) {
                var deltaX = (mouse.x / image.scale) - startX
                var deltaY = (mouse.y / image.scale) - startY

                // Swipe is only allowed when we're not zoomed in
                if (image.scale == pinchArea.minScale &&
                        (Math.abs(deltaX) > 50 || Math.abs(deltaY) > 50)) {
                    swipeDone = true

                    if (deltaX > 30) {
                        flickable.swipeRight()
                    } else if (deltaX < -30) {
                        flickable.swipeLeft()
                    }
                }
            }
        }

    }
}
