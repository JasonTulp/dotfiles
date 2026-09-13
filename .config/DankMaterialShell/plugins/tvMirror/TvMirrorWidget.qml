import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "tv-mirror"

    readonly property string tvMonitor: "HDMI-A-1"
    readonly property string mirrorMonitor: "DP-1"

    property int _hyprTrigger: 0

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root._hyprTrigger++;
            // mirroring adds and removes outputs, so the monitor list has to be
            // re-read before the icon can tell the three states apart
            if ((event.name ?? "").indexOf("monitor") !== -1) {
                Hyprland.refreshMonitors();
            }
        }
    }

    function hasMonitor(name) {
        _hyprTrigger;
        const monitors = Hyprland.monitors?.values || [];
        return monitors.some(m => m.name === name);
    }

    readonly property bool tvOn: hasMonitor(tvMonitor)

    // a mirroring output drops out of the monitor list entirely, so the centre
    // monitor going missing while the TV is present means it is mirroring
    readonly property bool mirroring: tvOn && !hasMonitor(mirrorMonitor)

    // BasePill adds this padding to each end of the content, so a square pill —
    // and therefore a circle, like the clipboard button next to it — needs the
    // content to be that much smaller than the bar is thick
    readonly property real dpr: parentScreen ? CompositorService.getScreenScale(parentScreen) : 1
    readonly property real hostPadding: (barConfig?.removeWidgetPadding ?? false) ? 0 : Theme.snap((barConfig?.widgetPadding ?? 12) * (widgetThickness / 30), dpr)
    readonly property real pillContentSize: Math.max(0, widgetThickness - hostPadding * 2)

    readonly property color iconColor: {
        if (root.mirroring) {
            return Theme.primary;
        }
        if (root.tvOn) {
            return Theme.widgetIconColor;
        }
        return Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.35);
    }

    pillClickAction: () => {
        if (!root.tvOn) {
            return;
        }
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/tv-mirror.sh"]);
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: root.pillContentSize
            implicitHeight: root.widgetThickness

            DankIcon {
                id: hIcon
                anchors.centerIn: parent
                name: "tv"
                size: root.iconSize
                color: root.iconColor

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            implicitHeight: root.pillContentSize

            DankIcon {
                id: vIcon
                anchors.centerIn: parent
                name: "tv"
                size: root.iconSize
                color: root.iconColor

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.shortDuration
                        easing.type: Theme.emphasizedEasing
                    }
                }
            }
        }
    }
}
