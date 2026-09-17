use std::env;
use std::fs;
use std::path::PathBuf;
use std::sync::OnceLock;
use std::time::{SystemTime, UNIX_EPOCH};

use serde::{Deserialize, Serialize};
use zbus::blocking::Connection;

static SIGNAL_CONNECTION: OnceLock<Connection> = OnceLock::new();

#[derive(Clone, Debug, Default, Deserialize, PartialEq, Eq, Serialize)]
pub struct RuntimeState {
    pub schema: u8,
    pub updated_at_ms: u128,
    pub headset_connected: Option<bool>,
    pub ambient_mode: Option<String>,
    pub microphone: Option<String>,
    pub lighting_enabled: Option<bool>,
    pub battery_percent: Option<u8>,
    pub game_chat_value: Option<u8>,
    pub bluetooth: Option<String>,
    pub sidetone_level: Option<String>,
}

impl RuntimeState {
    pub fn apply_input(&mut self, report: &[u8]) -> bool {
        let changed = match report {
            [0x02, value @ 0x00..=0x02] => {
                self.ambient_mode = Some(
                    match value {
                        0 => "off",
                        1 => "anc",
                        _ => "talkthru",
                    }
                    .into(),
                );
                true
            }
            [0x03, value @ 0x00..=0x02] => {
                self.bluetooth = Some(
                    match value {
                        0 => "disconnected",
                        1 => "connected",
                        _ => "pairing",
                    }
                    .into(),
                );
                true
            }
            [0x06, value @ 0x00..=0x01] => {
                self.microphone = Some(if *value == 0 { "muted" } else { "active" }.into());
                true
            }
            [0x07, value @ 0x00..=0x01] => {
                self.lighting_enabled = Some(*value == 1);
                true
            }
            [0x08, value @ 0x00..=0x64] => {
                self.battery_percent = Some(*value);
                true
            }
            [0x09, value @ 0x00..=0x01] => {
                self.headset_connected = Some(*value == 1);
                true
            }
            [0x10, value @ 0x00..=0x10] => {
                self.game_chat_value = Some(*value);
                true
            }
            _ => false,
        };
        if changed {
            self.touch();
        }
        changed
    }

    pub fn touch(&mut self) {
        self.updated_at_ms = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_or(0, |duration| duration.as_millis());
    }
}

pub fn path() -> Result<PathBuf, String> {
    let runtime = env::var_os("XDG_RUNTIME_DIR")
        .ok_or("XDG_RUNTIME_DIR is not set; refusing to store runtime state elsewhere")?;
    Ok(PathBuf::from(runtime).join("openjblquantum-state.json"))
}

pub fn load() -> Option<RuntimeState> {
    let path = path().ok()?;
    let bytes = fs::read(path).ok()?;
    serde_json::from_slice(&bytes).ok()
}

pub fn save(state: &mut RuntimeState) -> Result<(), String> {
    state.schema = 1;
    state.touch();
    let path = path()?;
    let temporary = path.with_extension(format!("tmp.{}", std::process::id()));
    let bytes = serde_json::to_vec_pretty(state).map_err(|error| error.to_string())?;
    fs::write(&temporary, bytes).map_err(|error| error.to_string())?;
    fs::rename(&temporary, &path).map_err(|error| error.to_string())?;
    emit_changed_signal();
    Ok(())
}

pub fn init_signal_service() -> Result<(), String> {
    let connection = Connection::session().map_err(|error| error.to_string())?;
    connection
        .request_name("org.openjblquantum.State")
        .map_err(|error| error.to_string())?;
    SIGNAL_CONNECTION
        .set(connection)
        .map_err(|_| "D-Bus signal service already initialized".to_string())
}

fn emit_changed_signal() {
    let Some(connection) = SIGNAL_CONNECTION.get() else {
        return;
    };
    let _ = connection.emit_signal(
        None::<&str>,
        "/org/openjblquantum/State",
        "org.openjblquantum.State",
        "Changed",
        &(),
    );
}

pub fn update_control(feature: &str, value: &str) -> Result<(), String> {
    let mut state = load().unwrap_or_default();
    match feature {
        "ambient" => state.ambient_mode = Some(value.into()),
        "lighting" => state.lighting_enabled = Some(value == "on"),
        "sidetone" => state.sidetone_level = Some(value.into()),
        _ => return Err(format!("unsupported cached control: {feature}")),
    }
    save(&mut state)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn applies_only_confirmed_input_reports() {
        let mut state = RuntimeState::default();
        assert!(state.apply_input(&[0x02, 0x02]));
        assert_eq!(state.ambient_mode.as_deref(), Some("talkthru"));
        assert!(state.apply_input(&[0x07, 0x01]));
        assert_eq!(state.lighting_enabled, Some(true));
        assert!(state.apply_input(&[0x08, 75]));
        assert_eq!(state.battery_percent, Some(75));
        assert!(!state.apply_input(&[0xff, 0x01]));
    }
}
