import QtQuick

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {}
    }
}
