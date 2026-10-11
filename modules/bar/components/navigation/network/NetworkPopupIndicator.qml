import QtQuick
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.network

IconButton {
  required property Item navigation
  required property Item navigationItem

  iconSource: AssetService.icon(NetworkService.wifi.connected
    ? "network-wireless"
    : "network-wireless-offline")
  iconSize: Theme.statusIconSize
  padding: Theme.statusIconPadding
  backgroundColor: hovered ? Theme.indicatorHoverBackground : Theme.indicatorBackground
  accessibleName: NetworkService.wifi.connected
  ? "Wi-Fi: " + NetworkService.wifi.connection
  : "Wi-Fi disconnected"

  onHoveredChanged: {
    if (hovered)
    navigation.setContent(navigationItem, navigationItem.content)
    else
    navigation.clearContent(navigationItem)
  }
}
