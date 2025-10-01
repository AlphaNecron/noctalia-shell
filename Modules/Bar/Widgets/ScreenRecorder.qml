import Quickshell
import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets
import qs.Modules.Bar.Extras

// Screen Recording Indicator
Item {
    id: root

    property ShellScreen screen
    property real scaling: 1.0

    // Widget properties passed from Bar.qml for per-instance settings
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    property var widgetMetadata: BarWidgetRegistry.widgetMetadata[widgetId]
    property var widgetSettings: {
        if (section && sectionWidgetIndex >= 0) {
            var widgets = Settings.data.bar.widgets[section];
            if (widgets && sectionWidgetIndex < widgets.length) {
                return widgets[sectionWidgetIndex];
            }
        }
        return {};
    }

    readonly property string displayMode: (widgetSettings.displayMode !== undefined) ? widgetSettings.displayMode : widgetMetadata.displayMode

    implicitWidth: pill.width
    implicitHeight: pill.height

    BarPill {
        id: pill
        icon: "camera-video"
        tooltipText: ScreenRecorderService.isRecording ? I18n.tr("tooltips.click-to-stop-recording") : I18n.tr("tooltips.click-to-start-recording")
        compact: (Settings.data.bar.density === "compact")
        onClicked: ScreenRecorderService.toggleRecording()
        onRightClicked: Quickshell.execDetached(["xdg-open", Settings.data.screenRecorder.directory])
        forceClose: displayMode === "alwaysHide" || !ScreenRecorderService.isRecording
        forceOpen: ScreenRecorderService.isRecording
        colorBg: ScreenRecorderService.isRecording ? Color.mPrimary : null
        colorFg: ScreenRecorderService.isRecording ? Color.mOnPrimary : null
        text: [Math.floor(ScreenRecorderService.currentTime / 60), ScreenRecorderService.currentTime % 60].map(v => String(v).padStart(2, '0')).join(":")
    }
}
