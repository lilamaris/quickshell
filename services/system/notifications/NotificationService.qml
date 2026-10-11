pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
  id: root

  readonly property var notifications: server.trackedNotifications
  property int unreadCount: 0
  property var toastNotification: null
  property bool toastVisible: false

  function markRead() {
    unreadCount = 0
  }

  function clearAll() {
    for (const notification of notifications.values.slice())
      notification.dismiss()
    toastVisible = false
    toastNotification = null
    unreadCount = 0
  }

  NotificationServer {
    id: server
    keepOnReload: true

    onNotification: notification => {
      notification.tracked = true
      if (notification.lastGeneration) return
      root.unreadCount++
      root.toastNotification = notification
      root.toastVisible = true
      toastTimer.restart()
    }
  }

  Connections {
    target: root.toastNotification
    function onClosed() {
      root.toastVisible = false
      root.toastNotification = null
    }
  }

  Timer {
    id: toastTimer
    interval: 5000
    onTriggered: root.toastVisible = false
  }
}
