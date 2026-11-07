import QtQuick
import qs.components.common
import qs.components.theme
import qs.services
import qs.services.system.audio

IconButton {
  required property Item navigation
  required property Item navigationItem

  iconSource: AssetService.icon(AudioService.backend.outputMuted
    || AudioService.backend.outputVolume === 0
    ? "audio-volume-muted"
    : AudioService.backend.outputVolume < 34
    ? "audio-volume-low"
    : AudioService.backend.outputVolume < 67
    ? "audio-volume-medium"
    : "audio-volume-high")
  iconSize: Theme.statusIconSize
  padding: Theme.statusIconPadding
  backgroundColor: hovered ? Theme.indicatorHoverBackground : Theme.indicatorBackground
  accessibleName: AudioService.backend.outputMuted
  ? "Audio muted"
  : "Volume " + Math.round(AudioService.backend.outputVolume) + "%"

  onHoveredChanged: {
    if (hovered)
    navigation.setContent(navigationItem, navigationItem.content)
    else
    navigation.clearContent(navigationItem)
  }
}
