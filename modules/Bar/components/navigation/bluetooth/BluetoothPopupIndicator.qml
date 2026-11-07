import QtQuick
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.bluetooth

IconButton {
  required property Item navigation
  required property Item navigationItem

  iconSource: AssetService.icon(!BluetoothService.backend.powered
    ? "bluetooth-disabled"
    : BluetoothService.backend.connectedDeviceCount > 0
    ? "bluetooth-active" : "bluetooth")
  iconSize: Theme.statusIconSize
  padding: Theme.statusIconPadding
  backgroundColor: hovered ? Theme.indicatorHoverBackground : Theme.indicatorBackground
  accessibleName: !BluetoothService.backend.available
  ? "Bluetooth unavailable"
  : !BluetoothService.backend.powered
  ? "Bluetooth off"
  : BluetoothService.backend.connectedDeviceCount > 0
  ? "Bluetooth connected" : "Bluetooth on"

  onHoveredChanged: {
    if (hovered)
    navigation.setContent(navigationItem, navigationItem.content)
    else
    navigation.clearContent(navigationItem)
  }
}
