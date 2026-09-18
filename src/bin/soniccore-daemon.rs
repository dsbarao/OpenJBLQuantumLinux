use std::env;
use std::process::{Command, ExitCode};

#[cfg(unix)]
use std::os::unix::process::CommandExt;

fn main() -> ExitCode {
    let soniccore = match env::current_exe()
        .ok()
        .and_then(|path| path.parent().map(|parent| parent.join("soniccore")))
    {
        Some(path) => path,
        None => {
            eprintln!("could not resolve the soniccore executable");
            return ExitCode::FAILURE;
        }
    };

    let mut command = Command::new(soniccore);
    command.arg("daemon");

    #[cfg(unix)]
    {
        let error = command.exec();
        eprintln!("could not start soniccore daemon: {error}");
        ExitCode::FAILURE
    }

    #[cfg(not(unix))]
    match command.status() {
        Ok(status) if status.success() => ExitCode::SUCCESS,
        Ok(status) => ExitCode::from(status.code().unwrap_or(1) as u8),
        Err(error) => {
            eprintln!("could not start soniccore daemon: {error}");
            ExitCode::FAILURE
        }
    }
}
