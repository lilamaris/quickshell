import QtQuick

QtObject {
  property bool connected: false
  property string device: "Unknown Device"
  property string connection: "Unknown Connection"
  property var availableNetworks: []
  property int signal: 0
  property bool isForceRefreshing: false
  property bool isConnecting: false
  property string connectionError: ""

  function refresh() {}
  function connectNetwork(ssid, password) {}
}
