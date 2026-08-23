pragma Singleton

import Quickshell
import qs.services.system.audio.wpctl

Singleton {
  readonly property WpctlAudio backend: WpctlAudio {}
}
