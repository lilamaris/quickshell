import QtQuick
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.notifications

IconButton {
  required property Item navigation
  required property Item navigationItem

  iconSource: AssetService.icon("notification")
  iconSize: Theme.statusIconSize
  padding: Theme.statusIconPadding
  backgroundColor: hovered ? Theme.indicatorHoverBackground : Theme.indicatorBackground
  accessibleName: "Notifications, " + NotificationService.unreadCount + " unread"

  Rectangle {
    visible: NotificationService.unreadCount > 0
    anchors.right: parent.right
    anchors.top: parent.top
    width: 8
    height: 8
    radius: 4
    color: Theme.accent
  }

  onHoveredChanged: {
    if (hovered) {
      NotificationService.markRead()
      navigation.setContent(navigationItem, navigationItem.content)
    } else {
      navigation.clearContent(navigationItem)
    }
  }

  onClicked: {
    NotificationService.markRead()
    navigation.setContent(navigationItem, navigationItem.content)
    navigation.focusPopup()
  }
}
