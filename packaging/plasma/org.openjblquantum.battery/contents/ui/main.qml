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
    property bool charging: false
    property string rawFeature: ""
    property string errorMessage: ""
    property string actionMessage: ""
    property string openSection: ""
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
            charging = false
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

        implicitWidth: 34 + Kirigami.Units.smallSpacing
        implicitHeight: Math.max(compactLayout.implicitHeight, 18)
        Layout.minimumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        onClicked: root.expanded = !root.expanded

        Item {
            id: compactLayout
            anchors.centerIn: parent
            width: 34
            height: 18

            Item {
                anchors.fill: parent

                Rectangle {
                    id: batteryBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30
                    height: 16
                    radius: 3
                    color: "transparent"
                    border.width: 1
                    border.color: root.batteryColor

                    Rectangle {
                        x: 2
                        y: 2
                        width: root.batteryPercent >= 0
                            ? Math.max(2, (parent.width - 4) * root.batteryPercent / 100)
                            : 0
                        height: parent.height - 4
                        radius: 1
                        color: root.batteryColor
                        opacity: 0.85
                    }

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 11
                        height: 11
                        source: "audio-headphones"
                    }

                    PlasmaComponents.Label {
                        visible: root.charging
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 1
                        anchors.topMargin: -3
                        text: "⚡"
                        color: "white"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }

                Rectangle {
                    anchors.left: batteryBody.right
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 7
                    radius: 1
                    color: root.batteryColor
                }
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
                checkable: true
                checked: root.openSection === "ambient"
                onClicked: root.openSection = checked ? "ambient" : ""
            }

            PlasmaComponents.Button {
                text: "Luzes"
                icon.name: "lightbulb"
                checkable: true
                checked: root.openSection === "lighting"
                onClicked: root.openSection = checked ? "lighting" : ""
            }

            PlasmaComponents.Button {
                text: "Sidetone"
                icon.name: "microphone-sensitivity-high"
                checkable: true
                checked: root.openSection === "sidetone"
                onClicked: root.openSection = checked ? "sidetone" : ""
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: controlOptions.implicitHeight + Kirigami.Units.largeSpacing * 2
            visible: root.openSection.length > 0
            radius: Kirigami.Units.cornerRadius
            color: Kirigami.Theme.backgroundColor
            border.width: 1
            border.color: Kirigami.Theme.disabledTextColor

            ColumnLayout {
                id: controlOptions
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.openSection === "ambient"
                        ? "Controle de som ambiente"
                        : root.openSection === "lighting" ? "Iluminação" : "Retorno do microfone"
                    font.bold: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "ambient"
                    PlasmaComponents.Button { text: "Desligado"; onClicked: root.runControl("ambient", "off") }
                    PlasmaComponents.Button { text: "ANC"; onClicked: root.runControl("ambient", "anc") }
                    PlasmaComponents.Button { text: "TalkThru"; onClicked: root.runControl("ambient", "talkthru") }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "lighting"
                    PlasmaComponents.Button { text: "Ligar"; icon.name: "lightbulb"; onClicked: root.runControl("lighting", "on") }
                    PlasmaComponents.Button { text: "Desligar"; icon.name: "lightbulb-off"; onClicked: root.runControl("lighting", "off") }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "sidetone"
                    PlasmaComponents.Button { text: "Off"; onClicked: root.runControl("sidetone", "off") }
                    PlasmaComponents.Button { text: "Baixo"; onClicked: root.runControl("sidetone", "low") }
                    PlasmaComponents.Button { text: "Médio"; onClicked: root.runControl("sidetone", "medium") }
                    PlasmaComponents.Button { text: "Alto"; onClicked: root.runControl("sidetone", "high") }
                }
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

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
