import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name
    WlrLayershell.namespace: `lilamaris-${name}`
    color: "transparent"
}
