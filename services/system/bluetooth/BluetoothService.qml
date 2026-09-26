pragma Singleton

import Quickshell
import qs.services.system.bluetooth.bluetoothctl

Singleton {
  readonly property BluetoothctlBluetooth backend: BluetoothctlBluetooth {}
}
