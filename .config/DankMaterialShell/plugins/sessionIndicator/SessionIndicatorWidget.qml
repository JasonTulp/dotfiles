import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "session-indicator"

    readonly property int sessionCount: 4
    readonly property int sessionSize: 100
    readonly property string screenName: parentScreen?.name ?? ""

    property int _hyprTrigger: 0

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root._hyprTrigger++;
        }
    }

    readonly property int currentSession: {
        _hyprTrigger;
        const monitors = Hyprland.monitors?.values || [];
        const own = monitors.find(m => m.name === root.screenName);
        const ordered = own ? [own].concat(monitors.filter(m => m !== own)) : monitors;
        for (const m of ordered) {
            const id = m.activeWorkspace?.id ?? -1;
            if (id > 0) {
                return Math.floor((id - 1) / sessionSize) + 1;
            }
        }
        return 1;
    }

    function switchToSession(target) {
        const script = Quickshell.env("HOME") + "/.config/hypr/scripts/session-switch.sh";
        Quickshell.execDetached([script, String(target)]);
    }

    // a session is "occupied" if any window lives on one of its numbered workspaces
    // (named workspaces like S/A/D are session-global and don't count toward any session)
    function sessionHasWindows(session) {
        _hyprTrigger;
        const base = (session - 1) * sessionSize;
        const toplevels = Hyprland.toplevels?.values || [];
        for (const t of toplevels) {
            const id = t.workspace?.id ?? -1;
            if (id > base && id <= base + sessionSize) {
                return true;
            }
        }
        return false;
    }

    // dimmer grey for empty sessions than the standard inactive dot
    readonly property color emptySessionColor: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.12)

    horizontalBarPill: Component {
        Item {
            // under-report width so BasePill's side padding shrinks to the top/bottom gap,
            // then give the right edge 2px extra
            implicitWidth: indicatorRow.implicitWidth - 2 * Math.max(0, hostPadding - edgeGap) + 2
            implicitHeight: root.widgetThickness

            readonly property real fontSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            readonly property real hostPadding: (root.barConfig?.removeWidgetPadding ?? false) ? 0 : (root.barConfig?.widgetPadding ?? 12) * (root.widgetThickness / 30)
            readonly property real edgeGap: (root.widgetThickness - indicatorRow.implicitHeight) / 2

            id: hArea

            Row {
                id: indicatorRow

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -1
                anchors.verticalCenter: parent.verticalCenter
                // compensate BasePill's half-pixel drift at fractional scale
                anchors.verticalCenterOffset: 1
                spacing: Theme.spacingXS

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "S" + root.currentSession
                    color: Theme.primary
                    font.pixelSize: hArea.fontSize
                    font.weight: Font.Bold
                    rightPadding: Theme.spacingXS
                }

                Repeater {
                    model: root.sessionCount

                    delegate: Item {
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter

                        readonly property bool isCurrent: (index + 1) === root.currentSession
                        readonly property bool hasWindows: root.sessionHasWindows(index + 1)

                        Rectangle {
                            anchors.centerIn: parent
                            width: isCurrent ? 11 : 10
                            height: width
                            radius: width / 2
                            color: isCurrent ? Theme.primary : dotMouseArea.containsMouse ? Theme.surfaceTextMedium : hasWindows ? Theme.surfaceTextAlpha : root.emptySessionColor
                        }

                        MouseArea {
                            id: dotMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.switchToSession(index + 1)
                        }
                    }
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: root.widgetThickness
            // under-report height so BasePill's end padding shrinks to the side gap
            implicitHeight: indicatorColumn.implicitHeight - 2 * Math.max(0, hostPadding - edgeGap)

            readonly property real fontSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            readonly property real hostPadding: (root.barConfig?.removeWidgetPadding ?? false) ? 0 : (root.barConfig?.widgetPadding ?? 12) * (root.widgetThickness / 30)
            readonly property real edgeGap: (root.widgetThickness - indicatorColumn.implicitWidth) / 2

            id: vArea

            Column {
                id: indicatorColumn

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXS

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "S" + root.currentSession
                    color: Theme.primary
                    font.pixelSize: vArea.fontSize
                    font.weight: Font.Bold
                    bottomPadding: Theme.spacingXS
                }

                Repeater {
                    model: root.sessionCount

                    delegate: Item {
                        width: 16
                        height: 16
                        anchors.horizontalCenter: parent.horizontalCenter

                        readonly property bool isCurrent: (index + 1) === root.currentSession
                        readonly property bool hasWindows: root.sessionHasWindows(index + 1)

                        Rectangle {
                            anchors.centerIn: parent
                            width: isCurrent ? 11 : 10
                            height: width
                            radius: width / 2
                            color: isCurrent ? Theme.primary : vDotMouseArea.containsMouse ? Theme.surfaceTextMedium : hasWindows ? Theme.surfaceTextAlpha : root.emptySessionColor
                        }

                        MouseArea {
                            id: vDotMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.switchToSession(index + 1)
                        }
                    }
                }
            }
        }
    }
}
