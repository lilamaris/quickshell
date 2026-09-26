import QtQuick

QtObject {
  property bool available: false
  property bool powered: false
  property bool scanning: false
  property var devices: []
  property string error: ""

  readonly property int connectedDeviceCount: {
    let count = 0
    for (let i = 0; i < devices.length; ++i) {
      if (devices[i].connected) ++count
    }
    return count
  }

  function refresh() {}
  function setPowered(enabled) {}
  function scan() {}
  function pair(address) {}
  function unpair(address) {}
  function connectDevice(address) {}
  function disconnectDevice(address) {}
}
