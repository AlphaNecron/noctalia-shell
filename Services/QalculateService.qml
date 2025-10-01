pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Singleton {
    id: root

    property bool active: Settings.isLoaded
    property bool loading: false
    property bool waitingForEval: true

    property var lastExpr: null
    property var result: null

    property bool qalculateAvailable: false
    property bool dependencyChecked: false

    signal evalCompleted

    // Check if cliphist is available
    Component.onCompleted: {
        checkQalculateAvailability();
    }

    function checkQalculateAvailability() {
        if (dependencyChecked)
            return;
        dependencyCheckProcess.command = ["which", "qalc"];
        dependencyCheckProcess.running = true;
    }

    Process {
        id: dependencyCheckProcess
        stdout: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            root.dependencyChecked = true;
            root.qalculateAvailable = exitCode === 0;
        }
    }

    Process {
        id: evalProc
        stdout: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            waitingForEval = false;
            if (exitCode !== 0) {
                result = null;
                return;
            }
            result = String(stdout.text);
            root.evalCompleted();
        }
    }

    Process {
        id: copyProc
        stdout: StdioCollector {}
    }

    function evaluate(expr) {
        if (!root.qalculateAvailable || expr == lastExpr)
            return;
        lastExpr = expr;
        loading = true;
        evalProc.command = ["qalc", "-t", expr];
        evalProc.running = true;
    }

    function copyToClipboard() {
        if (!root.qalculateAvailable || result == null)
            return;
        copyProc.command = ["wl-copy", result.trim()];
        copyProc.running = true;
    }
}
