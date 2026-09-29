import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.I3
import Quickshell.WindowManager
import qs.components.theme

Row {
  id: root

  property var targetScreen
  readonly property bool hyprlandSession: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
  readonly property bool i3Session: !hyprlandSession
    && (!!Quickshell.env("SWAYSOCK") || !!Quickshell.env("I3SOCK"))
  readonly property var genericProjection: !hyprlandSession && !i3Session && targetScreen
    ? WindowManager.screenProjection(targetScreen) : null

  spacing: Theme.spacingXs

  Repeater {
    model: root.hyprlandSession ? Array.from({ length: 10 }, (_, index) => index + 1)
      : root.i3Session ? I3.workspaces
      : root.genericProjection ? root.genericProjection.windowsets : []

    Rectangle {
      id: workspaceButton

      required property var modelData
      readonly property var hyprlandWorkspace: root.hyprlandSession
        ? Hyprland.workspaces.values.find(workspace => workspace.id === modelData) : null
      readonly property bool selected: root.hyprlandSession
        ? !!hyprlandWorkspace && hyprlandWorkspace.active
          && hyprlandWorkspace.monitor && root.targetScreen
          && hyprlandWorkspace.monitor.name === root.targetScreen.name
        : modelData.active
      readonly property bool urgent: root.hyprlandSession
        ? !!hyprlandWorkspace && hyprlandWorkspace.urgent : modelData.urgent
      readonly property string workspaceName: root.hyprlandSession
        ? String(modelData) : modelData.name

      visible: root.hyprlandSession ? true
        : root.i3Session ? root.targetScreen && modelData.monitor
          && modelData.monitor.name === root.targetScreen.name
        : modelData.shouldDisplay
      width: Math.max(28, Math.min(96, label.implicitWidth + 12))
      height: 24
      radius: Theme.spacingMd
      color: selected ? Theme.accentBackground
        : mouseArea.containsMouse || activeFocus ? Theme.indicatorHoverBackground
        : Theme.indicatorBackground

      activeFocusOnTab: visible && (root.hyprlandSession || root.i3Session
        || modelData.canActivate)
      Accessible.name: "Workspace " + workspaceName
        + (selected ? ", active" : "")
        + (urgent ? ", urgent" : "")
      Accessible.role: Accessible.Button

      function activate() {
        if (root.hyprlandSession) {
          if (hyprlandWorkspace) hyprlandWorkspace.activate()
          else Hyprland.dispatch("workspace " + modelData)
        } else if (root.i3Session || modelData.canActivate) {
          modelData.activate()
        }
      }

      Keys.onReturnPressed: activate()
      Keys.onEnterPressed: activate()
      Keys.onSpacePressed: activate()

      Behavior on color {
        ColorAnimation { duration: Theme.motionFast }
      }

      Text {
        id: label
        anchors.centerIn: parent
        width: parent.width - 12
        text: workspaceButton.workspaceName
        color: workspaceButton.urgent ? Theme.textError
          : workspaceButton.selected ? Theme.accent : Theme.textMuted
        opacity: root.hyprlandSession && !workspaceButton.hyprlandWorkspace ? 0.6 : 1
        font.pixelSize: Theme.fontSizeNormal
        font.weight: workspaceButton.selected ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
      }

      MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: workspaceButton.activeFocusOnTab
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: workspaceButton.activate()
      }
    }
  }
}
