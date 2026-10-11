pragma Singleton

import Quickshell

Singleton {
  function resolve(relativePath) {
    return Qt.resolvedUrl("../assets/" + relativePath)
  }

  function icon(name) {
    return resolve("icons/" + name + ".svg")
  }
}
