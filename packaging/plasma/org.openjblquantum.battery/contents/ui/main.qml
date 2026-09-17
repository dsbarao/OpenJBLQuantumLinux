import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.dbus as DBus

PlasmoidItem {
    id: root

    readonly property string command: "/bin/sh -lc \"$HOME/.cargo/bin/openjblquantum status --format json\""
    readonly property url equipmentImage: Qt.resolvedUrl("../images/jbl-quantum-810.png")
    property int batteryPercent: -1
    property bool charging: false
    property string rawFeature: ""
    property string errorMessage: ""
    property string actionMessage: ""
    property string openSection: ""
    property string ambientMode: "unknown"
    property var headsetConnected: null
    property string microphoneState: "unknown"
    property string sidetoneLevel: "unknown"
    property var lightingEnabled: null
    property string lightingColor: "unknown"
    property string logoColor: "unknown"
    property string ringColor: "unknown"
    property string lightingTarget: "both"
    property int gameChatValue: -1
    property bool controlBusy: false
    readonly property var lightingPresets: [
        { "key": "blue", "color": "#0029ff" },
        { "key": "cyan", "color": "#33ffcc" },
        { "key": "magenta", "color": "#ff00cc" },
        { "key": "red", "color": "#ff2020" },
        { "key": "green", "color": "#20ff66" },
        { "key": "white", "color": "#ffffff" }
    ]
    property bool updating: false
    readonly property bool deviceAvailable: batteryPercent >= 0
    readonly property bool daemonAvailable: daemonWatcher.registered
    readonly property color batteryColor: headsetConnected === false
        ? Kirigami.Theme.disabledTextColor
        : charging
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
        if (controlBusy) return
        controlBusy = true
        clearAction.stop()
        actionMessage = "Aplicando…"
        const controlCommand = `/bin/sh -lc "$HOME/.cargo/bin/openjblquantum set ${feature} ${value}"`
        executable.connectSource(controlCommand)
    }

    function ambientLabel(value) {
        if (value === "off") return "Desligado"
        if (value === "anc") return "ANC"
        if (value === "talkthru") return "TalkThru"
        return "Aguardando estado"
    }

    function sidetoneLabel(value) {
        if (value === "off") return "Desligado"
        if (value === "low") return "Baixo"
        if (value === "medium") return "Médio"
        if (value === "high") return "Alto"
        return "Aguardando estado"
    }

    function selectedLightingColor() {
        if (lightingTarget === "logo") return logoColor
        if (lightingTarget === "ring") return ringColor
        return lightingColor
    }

    function lightingFeature() {
        if (lightingTarget === "logo") return "logo-color"
        if (lightingTarget === "ring") return "ring-color"
        return "color"
    }

    function friendlyError(message) {
        const normalized = message.toLowerCase()
        if (normalized.includes("not found") || normalized.includes("não encontrado"))
            return "Dongle USB desconectado"
        if (normalized.includes("permission denied")
                || normalized.includes("permissão negada")
                || normalized.includes("operation not permitted"))
            return "Sem permissão para acessar o headset"
        return "Não foi possível ler o headset"
    }

    function applyResult(data) {
        const exitCode = Number(data["exit code"] ?? -1)
        const stdout = String(data.stdout ?? "").trim()
        const stderr = String(data.stderr ?? "").trim()
        if (exitCode !== 0) {
            batteryPercent = -1
            charging = false
            headsetConnected = false
            microphoneState = "unknown"
            ambientMode = "unknown"
            errorMessage = friendlyError(stderr)
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
            ambientMode = String(result.ambient_mode ?? "unknown")
            headsetConnected = result.headset_connected ?? null
            microphoneState = String(result.microphone ?? "unknown")
            sidetoneLevel = String(result.sidetone_level ?? "unknown")
            lightingEnabled = result.lighting_enabled ?? null
            lightingColor = String(result.lighting_color ?? "unknown")
            logoColor = String(result.logo_color ?? result.lighting_color ?? "unknown")
            ringColor = String(result.ring_color ?? result.lighting_color ?? "unknown")
            gameChatValue = result.game_chat_value === null ? -1 : Number(result.game_chat_value)
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
                        color: "#f5c542"
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
        Layout.minimumHeight: Kirigami.Units.gridUnit * 30
        Layout.preferredWidth: Kirigami.Units.gridUnit * 21
        Layout.preferredHeight: Kirigami.Units.gridUnit * 30
        spacing: Kirigami.Units.smallSpacing

        Image {
            source: root.equipmentImage
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
            Layout.preferredHeight: Kirigami.Units.gridUnit * 6
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.batteryPercent >= 0 ? `${root.batteryPercent}%` : "Indisponível"
            color: root.batteryColor
            font.pixelSize: Kirigami.Units.gridUnit * 1.7
            font.bold: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents.Label {
                text: root.headsetConnected === null
                    ? "Headset: aguardando"
                    : root.headsetConnected ? "● Ligado" : "○ Desligado"
                color: root.headsetConnected === true
                    ? Kirigami.Theme.positiveTextColor
                    : Kirigami.Theme.disabledTextColor
                font.bold: root.headsetConnected === true
            }

            PlasmaComponents.Label {
                text: root.microphoneState === "active"
                    ? "● Microfone ativo"
                    : root.microphoneState === "muted" ? "● Microfone mudo" : "Microfone aguardando"
                color: root.microphoneState === "muted"
                    ? Kirigami.Theme.negativeTextColor
                    : root.microphoneState === "active"
                        ? Kirigami.Theme.positiveTextColor
                        : Kirigami.Theme.disabledTextColor
                font.bold: root.microphoneState !== "unknown"
            }
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            Layout.minimumHeight: Kirigami.Units.gridUnit
            Layout.preferredHeight: Kirigami.Units.gridUnit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: root.actionMessage
            opacity: root.actionMessage.length > 0 ? 1 : 0
            color: root.errorMessage.length > 0
                ? Kirigami.Theme.negativeTextColor
                : Kirigami.Theme.positiveTextColor
            wrapMode: Text.Wrap
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Label {
                    text: "Chat"
                    font.bold: root.gameChatValue >= 0 && root.gameChatValue < 8
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    text: root.gameChatValue < 0
                        ? "Mova o dial para detectar"
                        : root.gameChatValue === 8 ? "Centro" : `${root.gameChatValue}/16`
                    opacity: 0.7
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    text: "Game"
                    font.bold: root.gameChatValue > 8
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: 3
                    color: Kirigami.Theme.disabledTextColor
                    opacity: 0.35
                }

                Rectangle {
                    visible: root.gameChatValue >= 0
                    x: (parent.width - width) * Math.max(0, Math.min(16, root.gameChatValue)) / 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: Kirigami.Theme.highlightColor
                    border.width: 2
                    border.color: Kirigami.Theme.backgroundColor
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing
            enabled: root.deviceAvailable && !root.controlBusy

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
                text: "Retorno"
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

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.openSection === "ambient"
                        ? `Atual: ${root.ambientLabel(root.ambientMode)}`
                        : root.openSection === "lighting"
                            ? root.lightingEnabled === null ? "Aguardando estado" : root.lightingEnabled ? "Atual: ligada" : "Atual: desligada"
                            : `Atual: ${root.sidetoneLabel(root.sidetoneLevel)}`
                    opacity: 0.7
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "ambient"
                    enabled: root.deviceAvailable && !root.controlBusy
                    PlasmaComponents.Button { text: "Desligado"; checkable: true; checked: root.ambientMode === "off"; onClicked: root.runControl("ambient", "off") }
                    PlasmaComponents.Button { text: "ANC"; checkable: true; checked: root.ambientMode === "anc"; onClicked: root.runControl("ambient", "anc") }
                    PlasmaComponents.Button { text: "TalkThru"; checkable: true; checked: root.ambientMode === "talkthru"; onClicked: root.runControl("ambient", "talkthru") }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "lighting"
                    enabled: root.deviceAvailable && !root.controlBusy
                    PlasmaComponents.Button { text: "Ligar"; icon.name: "lightbulb"; checkable: true; checked: root.lightingEnabled === true; onClicked: root.runControl("lighting", "on") }
                    PlasmaComponents.Button { text: "Desligar"; icon.name: "lightbulb-off"; checkable: true; checked: root.lightingEnabled === false; onClicked: root.runControl("lighting", "off") }
                }

                PlasmaComponents.Label {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "lighting"
                    text: "Cor sólida"
                    opacity: 0.7
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "lighting"
                    enabled: root.deviceAvailable && !root.controlBusy

                    PlasmaComponents.Button {
                        text: "Ambos"
                        checkable: true
                        checked: root.lightingTarget === "both"
                        onClicked: root.lightingTarget = "both"
                    }
                    PlasmaComponents.Button {
                        text: "Logotipo"
                        checkable: true
                        checked: root.lightingTarget === "logo"
                        onClicked: root.lightingTarget = "logo"
                    }
                    PlasmaComponents.Button {
                        text: "Anel / fundo"
                        checkable: true
                        checked: root.lightingTarget === "ring"
                        onClicked: root.lightingTarget = "ring"
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "lighting"
                    enabled: root.deviceAvailable && !root.controlBusy
                    spacing: Kirigami.Units.smallSpacing

                    Repeater {
                        model: root.lightingPresets

                        delegate: Rectangle {
                            required property var modelData
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 28
                            radius: Kirigami.Units.cornerRadius
                            color: modelData.color
                            border.width: root.selectedLightingColor() === modelData.key ? 3 : 1
                            border.color: root.selectedLightingColor() === modelData.key
                                ? Kirigami.Theme.highlightColor
                                : Kirigami.Theme.textColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.runControl(root.lightingFeature(), parent.modelData.key)
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.openSection === "sidetone"
                    enabled: root.deviceAvailable && !root.controlBusy
                    PlasmaComponents.Button { text: "Off"; checkable: true; checked: root.sidetoneLevel === "off"; onClicked: root.runControl("sidetone", "off") }
                    PlasmaComponents.Button { text: "Baixo"; checkable: true; checked: root.sidetoneLevel === "low"; onClicked: root.runControl("sidetone", "low") }
                    PlasmaComponents.Button { text: "Médio"; checkable: true; checked: root.sidetoneLevel === "medium"; onClicked: root.runControl("sidetone", "medium") }
                    PlasmaComponents.Button { text: "Alto"; checkable: true; checked: root.sidetoneLevel === "high"; onClicked: root.runControl("sidetone", "high") }
                }
            }
        }

        PlasmaComponents.Label {
            Layout.alignment: Qt.AlignHCenter
            visible: root.charging
            text: root.batteryPercent >= 100 ? "⚡ Carregado" : "⚡ Carregando"
            color: "#f5c542"
            font.bold: true
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            visible: root.errorMessage.length > 0 || !root.daemonAvailable
            horizontalAlignment: Text.AlignHCenter
            text: root.errorMessage.length > 0
                ? root.errorMessage
                : "Monitor em tempo real inativo"
            color: root.errorMessage.length > 0
                ? Kirigami.Theme.negativeTextColor
                : Kirigami.Theme.neutralTextColor
            wrapMode: Text.Wrap
            opacity: 0.85
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            if (sourceName !== root.command) {
                root.controlBusy = false
                const exitCode = Number(data["exit code"] ?? -1)
                const stderr = String(data.stderr ?? "").trim()
                if (exitCode === 0) {
                    root.errorMessage = ""
                    root.actionMessage = "Configuração aplicada"
                    clearAction.restart()
                    refreshAfterControl.restart()
                } else {
                    root.errorMessage = root.friendlyError(stderr)
                    root.actionMessage = root.errorMessage
                }
                return
            }
            root.updating = false
            root.applyResult(data)
        }
    }

    DBus.SignalWatcher {
        busType: DBus.BusType.Session
        service: "org.openjblquantum.State"
        path: "/org/openjblquantum/State"
        iface: "org.openjblquantum.State"
        enabled: true

        function dbusChanged() {
            root.refresh()
        }
    }

    DBus.DBusServiceWatcher {
        id: daemonWatcher
        busType: DBus.BusType.Session
        watchedService: "org.openjblquantum.State"

        onRegisteredChanged: {
            if (registered) root.refresh()
        }
    }

    Timer {
        id: refreshAfterControl
        interval: 300
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: clearAction
        interval: 1800
        repeat: false
        onTriggered: root.actionMessage = ""
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
