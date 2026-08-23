pragma Singleton

import Quickshell
import qs.services.system.network.nmcli

Singleton {
  readonly property Ethernet ethernet: NmcliNetwork {}
  readonly property Wifi wifi: NmcliWifi {}
}
