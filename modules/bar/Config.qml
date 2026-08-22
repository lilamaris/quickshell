import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

pragma Singleton
Singleton {
  id: root

  // 바 위치: "top" / "bottom" / "left" / "right"
  property string position: "top"

  // 가로 바(top/bottom) vs 세로 바(left/right)
  readonly property bool horizontal: position === "top" || position === "bottom"

  // 사용자가 커스텀하는 JSON 파일: ~/.config/quickshell/bar.json
  // 예: { "position": "bottom" }
  FileView {
    id: fileView
    path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/bar.json"
    watchChanges: true

    // 파일 저장 시 바로 반영 (쉘 재시작 불필요)
    onFileChanged: fileView.reload()

    onLoaded: root.load(text())
  }

  function load(content) {
    if (!content || !content.trim()) return

    let parsed = null
    try {
      parsed = JSON.parse(content)
    } catch (e) {
      return
    }

    const p = parsed ? parsed.position : undefined
    if (typeof p === "string" && ["top", "bottom", "left", "right"].includes(p)) {
      root.position = p
    }
  }

  function save() {
    fileView.setData(JSON.stringify({ position: root.position }))
  }
}
