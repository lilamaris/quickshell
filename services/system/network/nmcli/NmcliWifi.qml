import QtQuick
import Quickshell.Io
import qs.services.system.network

Wifi {
  id: root

  property Process connProcess: Process {
    command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]

    onExited: root.isForceRefreshing = false

    stdout: StdioCollector {
      onStreamFinished: {
        if (!this.text)
        return;

        const lines = this.text.trim().split('\n');
        for (var i = 0; i < lines.length; i++) {
          const parts = lines[i].split(":");
          if (parts.length !== 4) continue;

          const [device, type, state, connection] = parts;
          if (device === "lo") continue;
          if (type !== "wifi") continue;
          if (state !== "connected") continue;

          root.connected = true;
          root.device = device
          root.connection = connection
          return;
        }
      }
    }
  }

  function refresh(force) {
    if (force) root.isForceRefreshing = true;
    if (!connProcess.running) {
      connProcess.running = true;
    }
  }

  property Timer autoRefreshTimer: Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
