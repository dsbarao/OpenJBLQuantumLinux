import QtQuick
import QtQuick.Controls as QQC2
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
    property bool charging: false
    property string rawFeature: ""
    property string errorMessage: ""
    property string actionMessage: ""
    property bool updating: false
    readonly property color batteryColor: charging
        ? "#22d3ee"
        : batteryPercent < 0
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

    function runControl(feature, value) {
        actionMessage = "Aplicando…"
        const controlCommand = `/bin/sh -lc "$HOME/.cargo/bin/openjblquantum set ${feature} ${value}"`
        executable.connectSource(controlCommand)
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
            charging = result.charging === true
            rawFeature = String(result.raw_feature ?? "")
            errorMessage = ""
        } catch (error) {
            batteryPercent = -1
            charging = false
            errorMessage = `Resposta inválida: ${error}`
        }
    }

    compactRepresentation: MouseArea {
        id: compact

        implicitWidth: compactLayout.implicitWidth + Kirigami.Units.smallSpacing * 2
        implicitHeight: Math.max(compactLayout.implicitHeight, 24)
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
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

                    PlasmaComponents.Label {
                        visible: root.charging
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 1
                        anchors.topMargin: -4
                        text: "⚡"
                        color: "white"
                        font.pixelSize: 11
                        font.bold: true
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
                text: root.batteryPercent >= 0
                    ? root.charging ? `⚡ ${root.batteryPercent}%` : `${root.batteryPercent}%`
                    : "—"
                color: root.batteryColor
                font.bold: true
            }
        }
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 19
        Layout.minimumHeight: Kirigami.Units.gridUnit * 16
        Layout.preferredWidth: Kirigami.Units.gridUnit * 21
        Layout.preferredHeight: Kirigami.Units.gridUnit * 18
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
            visible: root.actionMessage.length > 0
            horizontalAlignment: Text.AlignHCenter
            text: root.actionMessage
            color: root.errorMessage.length > 0
                ? Kirigami.Theme.negativeTextColor
                : Kirigami.Theme.positiveTextColor
            wrapMode: Text.Wrap
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: "Ambiente"
                icon.name: "audio-headphones-symbolic"
                onClicked: ambientMenu.popup()
            }

            PlasmaComponents.Button {
                text: "Luzes"
                icon.name: "lightbulb"
                onClicked: lightingMenu.popup()
            }

            PlasmaComponents.Button {
                text: "Sidetone"
                icon.name: "microphone-sensitivity-high"
                onClicked: sidetoneMenu.popup()
            }
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            visible: root.charging
            text: "⚡ Carregando"
            color: root.batteryColor
            font.bold: true
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.errorMessage.length > 0
                ? root.errorMessage
                : "JBL Quantum 810 · leitura segura"
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
            if (sourceName !== root.command) {
                const exitCode = Number(data["exit code"] ?? -1)
                const stderr = String(data.stderr ?? "").trim()
                if (exitCode === 0) {
                    root.errorMessage = ""
                    root.actionMessage = "Configuração aplicada"
                } else {
                    root.errorMessage = stderr || "Falha ao aplicar configuração"
                    root.actionMessage = root.errorMessage
                }
                return
            }
            root.updating = false
            root.applyResult(data)
        }
    }

    QQC2.Menu {
        id: ambientMenu
        title: "Controle de som ambiente"
        QQC2.MenuItem { text: "Desligado"; onTriggered: root.runControl("ambient", "off") }
        QQC2.MenuItem { text: "ANC"; onTriggered: root.runControl("ambient", "anc") }
        QQC2.MenuItem { text: "TalkThru"; onTriggered: root.runControl("ambient", "talkthru") }
    }

    QQC2.Menu {
        id: lightingMenu
        title: "Iluminação"
        QQC2.MenuItem { text: "Ligar"; onTriggered: root.runControl("lighting", "on") }
        QQC2.MenuItem { text: "Desligar"; onTriggered: root.runControl("lighting", "off") }
    }

    QQC2.Menu {
        id: sidetoneMenu
        title: "Sidetone"
        QQC2.MenuItem { text: "Desligado"; onTriggered: root.runControl("sidetone", "off") }
        QQC2.MenuItem { text: "Baixo"; onTriggered: root.runControl("sidetone", "low") }
        QQC2.MenuItem { text: "Médio"; onTriggered: root.runControl("sidetone", "medium") }
        QQC2.MenuItem { text: "Alto"; onTriggered: root.runControl("sidetone", "high") }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
