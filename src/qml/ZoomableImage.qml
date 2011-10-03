import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

// Zoom features support (both pinch gesture and double click) taken from
// http://projects.developer.nokia.com/QuickFlickr/browser/qml/ZoomableImage.qml

Flickable {
    id: flickable
    clip: true
    contentHeight: imageContainer.height
    contentWidth: imageContainer.width
    onHeightChanged: image.calculateSize()

    property alias source: image.source
    signal imageReady()

    Item {
        id: imageContainer
        width: Math.max(image.width * image.scale, flickable.width)
        height: Math.max(image.height * image.scale, flickable.height)

        Image {
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
                    flickable.imageReady()
                    calculateSize();
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

        Timer {
            id: clickTimer
            interval: 350
            running: false
            repeat:  false
            onTriggered: showControls = !showControls
        }

        onDoubleClicked: {
            clickTimer.stop();
            mouse.accepted = true;

            if (image.scale > pinchArea.minScale) {
                image.scale = pinchArea.minScale;
                flickable.returnToBounds();
            } else {
                image.scale = 2.3;
            }
        }

        onClicked: {
            // There's a bug in Qt Components emitting a clicked signal
            // when a double click is done.
            clickTimer.start()
        }
    }
}