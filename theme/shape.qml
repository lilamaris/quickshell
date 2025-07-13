pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    component Rounding: QtObject {
        readonly property int sm: 12
        readonly property int md: 17
        readonly property int lg: 25
        readonly property int full: 1000
    }

    component Spacing: QtObject {
        readonly property int sm: 7
        readonly property int md: 10
        readonly property int lg: 25
    }

    component Padding: QtObject {
        readonly property int sm: 5
        readonly property int md: 10
        readonly property int lg: 15
    }

    component FontFamily: QtObject {
        readonly property string sans: "IBM Plex Sans"
        readonly property string mono: "JetBrains Mono NF"
        readonly property string material: "Material Symbols Rounded"
    }

    component FontSize: QtObject {
        readonly property int sm: 11
        readonly property int md: 13
        readonly property int lg: 18
    }
}
