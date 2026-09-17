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
    readonly property color batteryColor: batteryPercent < 0
        ? Kirigami.Theme.disabledTextColor
        : batteryPercent >= 60
            ? "#35c759"
            : batteryPercent >= 30 ? "#f5c542" : "#ff453a"

    Plasmoid.icon: "audio-headphones"
    Plasmoid.status: batteryPercent >= 0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

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
        implicitHeight: Math.max(compactLayout.implicitHeight, 24)
        onClicked: root.expanded = !root.expanded

        RowLayout {
            id: compactLayout
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Item {
                Layout.preferredWidth: 47
                Layout.preferredHeight: 24

                Rectangle {
                    id: batteryBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 42
                    height: 22
                    radius: 4
                    color: "transparent"
                    border.width: 2
                    border.color: root.batteryColor

                    Rectangle {
                        x: 3
                        y: 3
                        width: root.batteryPercent >= 0
                            ? Math.max(3, (parent.width - 6) * root.batteryPercent / 100)
                            : 0
                        height: parent.height - 6
                        radius: 2
                        color: root.batteryColor
                        opacity: 0.85
                    }

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: "audio-headphones"
                    }
                }

                Rectangle {
                    anchors.left: batteryBody.right
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 10
                    radius: 1
                    color: root.batteryColor
                }
            }

            PlasmaComponents.Label {
                text: root.batteryPercent >= 0 ? `${root.batteryPercent}%` : "—"
                color: root.batteryColor
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
            color: root.batteryColor
            font.pixelSize: Kirigami.Units.gridUnit * 2
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
