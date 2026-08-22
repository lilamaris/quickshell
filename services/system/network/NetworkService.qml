pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services.system.network.nmcli

Singleton {
  id: root

  readonly property Ethernet ethernet: NmcliNetwork {}
  readonly property Wifi wifi: NmcliWifi {}
}
