#!/usr/bin/env bash
set -euo pipefail

readonly PLASMOID_ID="org.openjblquantum.battery"
readonly PLASMOID_TARGET="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
readonly SERVICE_TARGET="$HOME/.config/systemd/user/openjblquantum-state.service"
readonly LAUNCHER_TARGET="$HOME/.local/share/applications/openjblquantum-battery.desktop"
readonly CARGO_BINARY="$HOME/.cargo/bin/openjblquantum"

show_plan() {
    printf '%s\n' 'Componentes do usuário que serão removidos:'
    printf '  %s\n' "$PLASMOID_TARGET"
    printf '  %s\n' "$SERVICE_TARGET"
    printf '  %s\n' "$LAUNCHER_TARGET"
    printf '  %s\n' "$CARGO_BINARY"
    printf '%s\n' 'Não serão removidos: repositório, capturas, documentação ou regra udev.'
}

if [[ "${1:-}" == "--check" ]]; then
    show_plan
    printf '%s\n' 'Prévia concluída. Nenhuma alteração foi feita.'
    exit 0
fi

if [[ "${1:-}" != "--confirm" || $# -ne 1 ]]; then
    printf '%s\n' 'uso: tools/uninstall-user.sh --check | --confirm' >&2
    exit 2
fi

show_plan

systemctl --user disable --now openjblquantum-state.service 2>/dev/null || true

if command -v kpackagetool6 >/dev/null 2>&1 && [[ -d "$PLASMOID_TARGET" ]]; then
    kpackagetool6 --type Plasma/Applet --remove "$PLASMOID_ID"
fi

rm -f -- "$SERVICE_TARGET" "$LAUNCHER_TARGET"
systemctl --user daemon-reload

if command -v cargo >/dev/null 2>&1 && [[ -x "$CARGO_BINARY" ]]; then
    cargo uninstall openjblquantum
fi

printf '%s\n' 'Componentes do JanBaLinux SonicCore instalados para o usuário foram removidos.'
printf '%s\n' 'Reinicie o Plasma manualmente se o widget ainda aparecer no painel.'
