pragma Singleton

import Quickshell
import Quickshell.Networking
import qs.services.system.network
import qs.services.system.network.quickshell

Singleton {
  readonly property Ethernet ethernet: Ethernet {
    available: Networking.devices.values.some(device => device.type === DeviceType.Wired)
    connected: Networking.devices.values.some(device =>
      device.type === DeviceType.Wired && device.connected)
  }
  readonly property Wifi wifi: QuickshellWifi {}
}
