import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.audio
import qs.services.system.bluetooth
import qs.services.system.network
import qs.services.system.notifications
import qs.modules.bar.components.navigation.notification
import qs.modules.bar.components.navigation.network
import qs.modules.bar.components.navigation.volume
import qs.modules.bar.components.navigation.bluetooth

Item {
  id: root

  anchors.fill: parent

  property Item activeAnchor: null
  property Component activeContent: null
  property bool popupOpen: false
  property bool hasPopupPosition: false
  property bool animatePopupPosition: false
  property real popupWidth: 0
  property real popupHeight: 0
  property real popupX: 0
  property int closeRevision: 0
  property bool changingPopupFocus: false

  Behavior on popupWidth {
    enabled: root.animatePopupPosition

    NumberAnimation {
      duration: Theme.motionNormal
      easing.type: Easing.OutCubic
    }
  }

  Behavior on popupHeight {
    enabled: root.animatePopupPosition

    NumberAnimation {
      duration: Theme.motionNormal
      easing.type: Easing.OutCubic
    }
  }

  Behavior on popupX {
    enabled: root.animatePopupPosition

    NumberAnimation {
      duration: Theme.motionNormal
      easing.type: Easing.OutCubic
    }
  }

  function setContent(anchor, content) {
    ++root.closeRevision
    root.activeAnchor = anchor
    root.activeContent = content
    root.popupOpen = true
  }

  function clearContent(anchor) {
    if (root.activeAnchor !== anchor || !root.popupOpen) return
    const revision = ++root.closeRevision
    Qt.callLater(() => {
        if (revision !== root.closeRevision || root.activeAnchor !== anchor || !root.popupOpen)
        return
        if (root.changingPopupFocus || popupWindow.grabFocus
          || anchor.indicatorHovered || popupHover.hovered) return
        root.popupOpen = false
    })
  }

  function keepContentOpen() {
    if (root.activeContent === null) return
    ++root.closeRevision
    root.popupOpen = true
  }

  function finishClosing() {
    if (root.popupOpen) return
    popupWindow.visible = false
    popupWindow.grabFocus = false
    root.activeContent = null
    root.activeAnchor = null
    root.hasPopupPosition = false
    root.animatePopupPosition = false
    root.popupWidth = 0
    root.popupHeight = 0
  }

  function focusPopup() {
    if (!root.popupOpen || popupWindow.grabFocus || root.changingPopupFocus) return
    ++root.closeRevision
    root.changingPopupFocus = true
    popupWindow.visible = false
    popupWindow.grabFocus = true
    Qt.callLater(() => {
        if (root.popupOpen && root.activeContent !== null) popupWindow.visible = true
        root.changingPopupFocus = false
    })
  }

  function positionPopup() {
    if (!root.activeAnchor || !contentLoader.item) return

    const width = contentLoader.item.implicitWidth
    const anchorCenter = root.activeAnchor.mapToItem(root, root.activeAnchor.width / 2, 0).x
    const targetX = anchorCenter - width / 2

    root.animatePopupPosition = root.hasPopupPosition
    root.popupWidth = width
    root.popupHeight = contentLoader.item.implicitHeight
    root.popupX = targetX
    root.hasPopupPosition = true
    if (root.popupOpen && !root.changingPopupFocus) popupWindow.visible = true
  }

  FlexboxLayout {
    anchors.fill: parent

    direction: FlexboxLayout.Row
    alignItems: FlexboxLayout.AlignCenter
    justifyContent: FlexboxLayout.JustifyCenter

    NavigationItem {
      id: notifications

      indicator: Component {
        NotificationIndicator {
          navigation: root
          navigationItem: notifications
        }
      }
      content: Component {
        NotificationCenter {}
      }
    }

    NavigationItem {
      id: network

      indicator: Component {
        NetworkPopupIndicator {
          navigation: root
          navigationItem: network
        }
      }

      content: Component {
        NetworkPopup {
          onKeyboardFocusRequested: root.focusPopup()
        }
      }
    }

    NavigationItem {
      id: bluetooth

      indicator: Component {
        BluetoothPopupIndicator {
          navigation: root
          navigationItem: bluetooth
        }
      }

      content: Component {
        BluetoothPopup {}
      }
    }

    NavigationItem {
      id: volume

      indicator: Component {
        VolumePopupIndicator {
          navigation: root
          navigationItem: volume
        }
      }

      content: Component {
        VolumePopup {}
      }
    }
  }

  PopupWindow {
    id: popupWindow

    visible: false
    grabFocus: false
    onVisibleChanged: {
      if (!visible && root.popupOpen && !root.changingPopupFocus) {
        root.popupOpen = false
        root.finishClosing()
      }
    }

    color: "transparent"

    // Keep the window surface stable while the visible box moves and resizes.
    implicitWidth: Math.min(400, root.width)
    implicitHeight: 486
    mask: Region {
      x: popupHitArea.x
      y: popupHitArea.y
      width: root.popupOpen ? popupHitArea.width : 0
      height: root.popupOpen ? popupHitArea.height : 0
    }

    anchor {
      item: root
      rect.x: (root.width - popupWindow.implicitWidth) / 2
      rect.y: root.height
    }

    Item {
      anchors.fill: parent

      Item {
        id: popupHitArea
        x: root.popupX - (root.width - popupWindow.implicitWidth) / 2
        y: 0
        width: root.popupWidth
        height: root.popupHeight + 6

        HoverHandler {
          id: popupHover
          enabled: root.popupOpen
          onHoveredChanged: {
            if (hovered)
            root.keepContentOpen()
            else
            root.clearContent(root.activeAnchor)
          }
        }

        Rectangle {
          id: popupBox
          y: 6
          width: parent.width
          height: parent.height - y

          radius: Theme.popupRadius
          color: Theme.popupBackground
          clip: true
          opacity: root.popupOpen ? 1 : 0

          transform: Translate {
            y: root.popupOpen ? 0 : -4

            Behavior on y {
              NumberAnimation {
                duration: Theme.motionMedium
                easing.type: Easing.OutCubic
                onStopped: root.finishClosing()
              }
            }
          }

          Behavior on opacity {
            NumberAnimation {
              duration: Theme.motionFast
              easing.type: Easing.OutCubic
            }
          }

          Loader {
            id: contentLoader
            sourceComponent: root.activeContent
            onLoaded: root.positionPopup()
            onImplicitWidthChanged: root.positionPopup()
            onImplicitHeightChanged: root.positionPopup()
          }
        }
      }
    }
  }
}
