import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property string command: "/bin/sh -lc \"$HOME/.cargo/bin/openjblquantum status --format json\""
    property int batteryPercent: -1
    property string rawFeature: ""
    property string errorMessage: ""
    property bool updating: false

    Plasmoid.icon: "audio-headphones"
    Plasmoid.status: batteryPercent >= 0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.toolTipMainText: "JBL Quantum 810"
    Plasmoid.toolTipSubText: errorMessage.length > 0
        ? errorMessage
        : batteryPercent >= 0 ? `Bateria: ${batteryPercent}%` : "Bateria indisponível"

    function refresh() {
        if (updating) {
            return
        }
        updating = true
        errorMessage = ""
        executable.connectSource(command)
    }

    function applyResult(data) {
        const exitCode = Number(data["exit code"] ?? -1)
        const stdout = String(data.stdout ?? "").trim()
        const stderr = String(data.stderr ?? "").trim()
        if (exitCode !== 0) {
            batteryPercent = -1
            errorMessage = stderr || "Headset não encontrado"
            return
        }
        try {
            const result = JSON.parse(stdout)
            const percentage = Number(result.battery_percent)
            if (!Number.isFinite(percentage) || percentage < 0 || percentage > 100) {
                throw new Error("percentual inválido")
            }
            batteryPercent = percentage
            rawFeature = String(result.raw_feature ?? "")
            errorMessage = ""
        } catch (error) {
            batteryPercent = -1
            errorMessage = `Resposta inválida: ${error}`
        }
    }

    compactRepresentation: MouseArea {
        id: compact

        implicitWidth: compactLayout.implicitWidth + Kirigami.Units.smallSpacing * 2
        implicitHeight: Math.max(compactLayout.implicitHeight, Kirigami.Units.iconSizes.small)
        onClicked: root.expanded = !root.expanded

        RowLayout {
            id: compactLayout
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "audio-headphones"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }

            PlasmaComponents.Label {
                text: root.batteryPercent >= 0 ? `${root.batteryPercent}%` : "—"
                color: root.batteryPercent >= 0 && root.batteryPercent <= 20
                    ? Kirigami.Theme.negativeTextColor
                    : Kirigami.Theme.textColor
                font.bold: true
            }
        }
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 9
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: Kirigami.Units.gridUnit * 11
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            source: "audio-headphones"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.huge
            Layout.preferredHeight: Kirigami.Units.iconSizes.huge
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.batteryPercent >= 0 ? `${root.batteryPercent}%` : "Indisponível"
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 2
            font.bold: true
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.errorMessage.length > 0
                ? root.errorMessage
                : root.rawFeature.length > 0 ? `Feature Report: ${root.rawFeature}` : "Somente leitura"
            wrapMode: Text.Wrap
            opacity: 0.7
        }

        PlasmaComponents.Button {
            Layout.alignment: Qt.AlignHCenter
            text: root.updating ? "Atualizando…" : "Atualizar"
            icon.name: "view-refresh"
            enabled: !root.updating
            onClicked: root.refresh()
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            root.updating = false
            root.applyResult(data)
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
