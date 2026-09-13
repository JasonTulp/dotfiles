import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "session-workspaces"

    readonly property int sessionSize: 100
    readonly property string screenName: parentScreen?.name ?? ""

    // re-evaluate workspace state on any Hyprland event
    property int _hyprTrigger: 0

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root._hyprTrigger++;
        }
    }

    // session derived from visible workspace ids (id 104 -> session 2, ws 4)
    readonly property int activeWsId: {
        _hyprTrigger;
        const monitor = Hyprland.monitors?.values?.find(m => m.name === root.screenName);
        return monitor?.activeWorkspace?.id ?? 1;
    }

    readonly property int currentSession: {
        _hyprTrigger;
        if (activeWsId > 0) {
            return Math.floor((activeWsId - 1) / sessionSize) + 1;
        }
        // this monitor shows a named workspace (S); infer from any other monitor
        const monitors = Hyprland.monitors?.values || [];
        for (const m of monitors) {
            const id = m.activeWorkspace?.id ?? -1;
            if (id > 0) {
                return Math.floor((id - 1) / sessionSize) + 1;
            }
        }
        return 1;
    }

    readonly property var wsList: {
        _hyprTrigger;
        const base = (currentSession - 1) * sessionSize;
        const all = (Hyprland.workspaces?.values || []).filter(ws => ws.monitor?.name === root.screenName);
        const numbered = all.filter(ws => ws.id > base && ws.id <= base + sessionSize).sort((a, b) => a.id - b.id);
        // named workspaces (e.g. S) are session-global; special workspaces stay hidden
        const named = all.filter(ws => ws.id < 0 && !ws.name.startsWith("special")).sort((a, b) => a.name.localeCompare(b.name));
        return numbered.concat(named);
    }

    function workspaceLabel(ws) {
        return ws.id > 0 ? ws.id % sessionSize : ws.name;
    }

    function activateWorkspace(ws) {
        if (ws.id > 0) {
            Hyprland.dispatch("workspace " + ws.id);
        } else {
            Hyprland.dispatch("workspace name:" + ws.name);
        }
    }

    function workspaceIcons(wsId, isActiveWs) {
        _hyprTrigger;
        if (!SettingsData.showWorkspaceApps) {
            return [];
        }
        const wins = CompositorService.sortedToplevels || [];
        const hyprToplevels = Array.from(Hyprland.toplevels?.values || []);
        const byApp = {};
        wins.forEach((w, i) => {
            if (!w) {
                return;
            }
            const ht = hyprToplevels.find(ht => ht.wayland === w);
            if (ht?.workspace?.id !== wsId) {
                return;
            }
            const keyBase = w.app_id || w.appId || w.class || w.windowClass || "unknown";
            const moddedId = Paths.moddedAppId(keyBase);
            const key = isActiveWs || !SettingsData.groupWorkspaceApps ? `${moddedId}_${i}` : moddedId;
            if (byApp[key]) {
                return;
            }
            const desktopEntry = DesktopEntries.heuristicLookup(moddedId);
            byApp[key] = {
                "icon": Paths.getAppIcon(moddedId, desktopEntry),
                "active": !!w.activated,
                "fallbackText": Paths.getAppName(moddedId, desktopEntry) || "?"
            };
        });
        return Object.values(byApp).slice(0, SettingsData.maxWorkspaceIcons);
    }

    verticalBarPill: Component {
        Item {
            id: vPillArea

            implicitWidth: root.widgetThickness
            // under-report height so BasePill's end padding shrinks to the side gap
            implicitHeight: vMainColumn.implicitHeight - 2 * Math.max(0, hostPadding - edgeGap)

            readonly property real widgetH: root.widgetThickness
            readonly property real appIconSize: Theme.barIconSize(root.barThickness, -6 + SettingsData.workspaceAppIconSizeOffset, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            readonly property real pillWidth: SettingsData.showWorkspaceApps ? Math.max(widgetH * 0.7, appIconSize + Theme.spacingXS * 2) : widgetH * 0.5
            readonly property real hostPadding: (root.barConfig?.removeWidgetPadding ?? false) ? 0 : (root.barConfig?.widgetPadding ?? 12) * (widgetH / 30)
            readonly property real edgeGap: (widgetH - pillWidth) / 2
            readonly property real pillFontSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            readonly property color activeTextColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.95)

            Column {
                id: vMainColumn

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXS

                Repeater {
                    model: ScriptModel {
                        values: root.wsList
                    }

                    delegate: Rectangle {
                        id: vWsPill

                        readonly property bool isActive: modelData.id === root.activeWsId
                        readonly property var loadedIcons: root.workspaceIcons(modelData.id, isActive)

                        readonly property real baseHeight: isActive ? Math.max(vPillArea.widgetH * 1.05, vPillArea.appIconSize * 1.6) : Math.max(vPillArea.widgetH * 0.7, vPillArea.appIconSize * 1.2)
                        readonly property real iconsExtraHeight: {
                            const numIcons = loadedIcons.length;
                            if (!SettingsData.showWorkspaceApps || numIcons === 0) {
                                return 0;
                            }
                            return numIcons * vPillArea.appIconSize + (numIcons - 1) * Theme.spacingXS + (isActive ? Theme.spacingXS : 0);
                        }

                        width: vPillArea.pillWidth
                        height: Math.max(baseHeight + iconsExtraHeight, vWsContent.implicitHeight + Theme.spacingS)
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: Theme.cornerRadius
                        color: vWsPill.isActive ? Theme.primary : Theme.surfaceTextAlpha

                        Behavior on height {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }

                        Column {
                            id: vWsContent
                            anchors.centerIn: parent
                            spacing: 4

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.workspaceLabel(modelData)
                                color: vWsPill.isActive ? vPillArea.activeTextColor : Theme.surfaceTextMedium
                                font.pixelSize: vPillArea.pillFontSize
                                font.weight: vWsPill.isActive ? Font.DemiBold : Font.Normal
                            }

                            Repeater {
                                model: ScriptModel {
                                    values: vWsPill.loadedIcons
                                }

                                delegate: Item {
                                    width: vPillArea.appIconSize
                                    height: vPillArea.appIconSize
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    IconImage {
                                        id: vAppIcon
                                        anchors.fill: parent
                                        source: modelData.icon || ""
                                        opacity: modelData.active ? 1 : 0.6
                                        visible: status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        visible: vAppIcon.status !== Image.Ready
                                        color: Theme.surfaceContainer
                                        radius: Theme.cornerRadius * (vPillArea.appIconSize / 40)
                                        border.width: 1
                                        border.color: Theme.primarySelected
                                        opacity: (modelData.active || vWsPill.isActive) ? 1 : 0.6

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: (modelData.fallbackText || "?").charAt(0).toUpperCase()
                                            font.pixelSize: parent.width * 0.45
                                            color: Theme.primary
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activateWorkspace(modelData)
                        }
                    }
                }
            }
        }
    }

    horizontalBarPill: Component {
        Item {
            // under-report width so BasePill's side padding shrinks to the top/bottom gap
            implicitWidth: mainRow.implicitWidth - 2 * Math.max(0, hostPadding - edgeGap)
            implicitHeight: root.widgetThickness

            readonly property real widgetH: root.widgetThickness
            readonly property real appIconSize: Theme.barIconSize(root.barThickness, -6 + SettingsData.workspaceAppIconSizeOffset, root.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
            readonly property real pillHeight: SettingsData.showWorkspaceApps ? Math.max(widgetH * 0.7, appIconSize + Theme.spacingXS * 2) : widgetH * 0.5
            readonly property real hostPadding: (root.barConfig?.removeWidgetPadding ?? false) ? 0 : (root.barConfig?.widgetPadding ?? 12) * (widgetH / 30)
            readonly property real edgeGap: (widgetH - pillHeight) / 2
            readonly property real pillFontSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            readonly property color activeTextColor: Qt.rgba(Theme.surfaceContainer.r, Theme.surfaceContainer.g, Theme.surfaceContainer.b, 0.95)

            id: pillArea

            Row {
                id: mainRow

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                // compensate BasePill's half-pixel drift at fractional scale
                anchors.verticalCenterOffset: 1
                spacing: Theme.spacingXS

                Repeater {
                    model: ScriptModel {
                        values: root.wsList
                    }

                    delegate: Rectangle {
                        id: wsPill

                        readonly property bool isActive: modelData.id === root.activeWsId
                        readonly property var loadedIcons: root.workspaceIcons(modelData.id, isActive)

                        readonly property real baseWidth: isActive ? Math.max(pillArea.widgetH * 1.05, pillArea.appIconSize * 1.6) : Math.max(pillArea.widgetH * 0.7, pillArea.appIconSize * 1.2)
                        readonly property real iconsExtraWidth: {
                            const numIcons = loadedIcons.length;
                            if (!SettingsData.showWorkspaceApps || numIcons === 0) {
                                return 0;
                            }
                            return numIcons * pillArea.appIconSize + (numIcons - 1) * Theme.spacingXS + (isActive ? Theme.spacingXS : 0);
                        }

                        width: Math.max(baseWidth + iconsExtraWidth, wsContent.implicitWidth + Theme.spacingS)
                        height: pillArea.pillHeight
                        radius: Theme.cornerRadius
                        color: wsPill.isActive ? Theme.primary : Theme.surfaceTextAlpha

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.mediumDuration
                                easing.type: Theme.emphasizedEasing
                            }
                        }

                        Row {
                            id: wsContent
                            anchors.centerIn: parent
                            spacing: 4

                            StyledText {
                                id: wsNumber
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.workspaceLabel(modelData)
                                color: wsPill.isActive ? pillArea.activeTextColor : Theme.surfaceTextMedium
                                font.pixelSize: pillArea.pillFontSize
                                font.weight: wsPill.isActive ? Font.DemiBold : Font.Normal
                            }

                            Repeater {
                                model: ScriptModel {
                                    values: wsPill.loadedIcons
                                }

                                delegate: Item {
                                    width: pillArea.appIconSize
                                    height: pillArea.appIconSize
                                    anchors.verticalCenter: parent.verticalCenter

                                    IconImage {
                                        id: appIcon
                                        anchors.fill: parent
                                        source: modelData.icon || ""
                                        opacity: modelData.active ? 1 : 0.6
                                        visible: status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        visible: appIcon.status !== Image.Ready
                                        color: Theme.surfaceContainer
                                        radius: Theme.cornerRadius * (pillArea.appIconSize / 40)
                                        border.width: 1
                                        border.color: Theme.primarySelected
                                        opacity: (modelData.active || wsPill.isActive) ? 1 : 0.6

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: (modelData.fallbackText || "?").charAt(0).toUpperCase()
                                            font.pixelSize: parent.width * 0.45
                                            color: Theme.primary
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activateWorkspace(modelData)
                        }
                    }
                }
            }
        }
    }
}
