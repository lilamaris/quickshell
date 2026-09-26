pragma Singleton

import Quickshell
import qs.services.system.audio.pipewire

Singleton {
  readonly property PipewireAudio backend: PipewireAudio {}
}
