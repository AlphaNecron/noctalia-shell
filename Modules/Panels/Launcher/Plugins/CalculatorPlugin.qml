import Quickshell
import QtQuick
import qs.Commons

Item {
    property var launcher: null
    property string name: I18n.tr("plugins.calculator")
    property var result: null

    Connections {
        target: QalculateService
        function onEvalCompleted() {
            if (launcher)
                launcher.updateResults();
        }
    }

    function handleCommand(query) {
        return query.startsWith(">calc") || (query.startsWith(">") && query.length > 1);
    }

    function commands() {
        return [
            {
                "name": ">calc",
                "description": I18n.tr("plugins.calculator-description"),
                "icon": "accessories-calculator",
                "isImage": false,
                "onActivate": function () {
                    launcher.setSearchText(">calc ");
                }
            }
        ];
    }

    function getResults(query) {
        let expression = "";

        if (query.startsWith(">calc")) {
            expression = query.substring(5).trim();
        } else if (query.startsWith(">")) {
            expression = query.substring(1).trim();
        } else {
            return [];
        }

        if (!expression) {
            return [
                {
                    "name": I18n.tr("plugins.calculator-name"),
                    "description": I18n.tr("plugins.calculator-enter-expression"),
                    "icon": "accessories-calculator",
                    "isImage": false,
                    "onActivate": function () {}
                }
            ];
        }

        try {
            expression = expression.trim();
            QalculateService.evaluate(expression);

            let result = QalculateService.result;
            if (result == null)
                throw new Error();
            result = result.trim();
            return [
                {
                    "name": result,
                    "description": `${expression.trim()} = ${result}`,
                    "icon": "accessories-calculator",
                    "isImage": false,
                    "onActivate": function () {
                        QalculateService.copyToClipboard();
                        launcher.close();
                    }
                }
            ];
        } catch (error) {
            return [
                {
                    "name": I18n.tr("plugins.calculator-error"),
                    "description": error.message || "Invalid expression",
                    "icon": "dialog-error",
                    "isImage": false,
                    "onActivate": function () {}
                }
            ];
        }
    }
}
