use clap::Command;
use log::{debug, error};
use plugin::{Plugin, PluginManager};
use prettytable::{cell, color, format::consts, row, Attr, Cell, Row, Table};
use serde::Deserialize;
use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::time::Instant;
use walkdir::{DirEntry, WalkDir};

mod errors;
mod plugin;

const PKG_VERSION: &str = env!("CARGO_PKG_VERSION");
const PKG_DESCRIPTION: &str = env!("CARGO_PKG_DESCRIPTION");

#[derive(Deserialize, Debug)]
struct GithubRelease {
    tag_name: Option<String>,
}

fn is_not_hidden(entry: &DirEntry) -> bool {
    entry
        .file_name()
        .to_str()
        .map(|s| entry.depth() == 0 || !s.starts_with('.'))
        .unwrap_or(false)
}

#[tokio::main]
async fn main() -> Result<(), errors::GenericError> {
    dotenv::dotenv()
        .or_else(|_| dotenv::from_filename(".env.scarper"))
        .ok();

    if env::var("RUST_LOG").is_err() {
        env::set_var("RUST_LOG", "scarper=info");
    }

    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    let cli_app = Command::new("scarper")
        .bin_name("scarper")
        .version(PKG_VERSION)
        .about(PKG_DESCRIPTION)
        .arg_required_else_help(true)
        .propagate_version(true)
        .subcommand(Command::new("status").about("Check the status of all packages."))
        .subcommand(
            Command::new("update").about("Update the scarper repo data and binary."),
        )
        .subcommand(Command::new("install").about("Install a package."))
        .subcommand(Command::new("uninstall").about("Uninstall a package."));

    let matches = cli_app.get_matches();

    let start = Instant::now();
    match matches.subcommand_name() {
        Some("status") => todo!(),
        Some("update") => todo!(),
        Some("install") => todo!(),
        Some("uninstall") => todo!(),
        _ => {
            error!("Invalid subcommand");
            // std::process::exit(1);
        }
    }

    let client = reqwest::Client::builder()
        .user_agent("scarper/0.1")
        .build()?;

    // let config = parse("scarper_watch.toml");
    // let mut table = Table::new();
    // table.set_titles(row!["Package Name", "Status"]);
    // table.set_format(*consts::FORMAT_NO_LINESEP_WITH_TITLE);

    let mut pm = PluginManager::new();

    for entry in WalkDir::new("plugins")
        .max_depth(2)
        .into_iter()
        .filter_entry(|e| is_not_hidden(e))
        .filter_map(|e| e.ok())
        .filter(|e| !e.file_type().is_dir())
    {
        let filename = entry
            .path()
            .to_str()
            .expect("Failed to convert path to string");

        debug!("Loading plugin: {filename:?}");
        pm.load_plugin(filename)
            .expect(&format!("Failed to load plugin {filename:?}"));
    }

    // for package in config.packages {
    //     let location = package.location.unwrap_or_else(|| "unknown".to_string());
    //     let name = package.name.unwrap();
    //     let version = package.version;

    //     let mut loc = location.split(':');
    //     let location_type = loc.next();
    //     let location_uri = loc.next();

    //     match location_type {
    //         Some("github") => {
    //             let uri = format!(
    //                 "https://api.github.com/repos/{}/releases/latest",
    //                 location_uri.unwrap()
    //             );

    //             let json: GithubRelease = client.get(&uri).send().await?.json().await?;

    //             if json.tag_name == version {
    //                 table.add_row(Row::new(vec![
    //                     Cell::new(name.as_str()).with_style(Attr::Bold),
    //                     Cell::new("up-to date")
    //                         .with_style(Attr::ForegroundColor(color::GREEN)),
    //                 ]));
    //             } else {
    //                 table.add_row(Row::new(vec![
    //                     Cell::new(name.as_str()).with_style(Attr::Bold),
    //                     Cell::new(json.tag_name.unwrap().as_str())
    //                         .with_style(Attr::ForegroundColor(color::RED)),
    //                 ]));
    //             }
    //         }
    //         Some("package") => {
    //             let current_version = pm.get_package_version(location_uri.unwrap());
    //             if current_version == version.unwrap().as_str() {
    //                 table.add_row(Row::new(vec![
    //                     Cell::new(name.as_str()).with_style(Attr::Bold),
    //                     Cell::new("up-to date")
    //                         .with_style(Attr::ForegroundColor(color::GREEN)),
    //                 ]));
    //             } else {
    //                 table.add_row(Row::new(vec![
    //                     Cell::new(name.as_str()).with_style(Attr::Bold),
    //                     Cell::new(current_version)
    //                         .with_style(Attr::ForegroundColor(color::RED)),
    //                 ]));
    //             }
    //         }
    //         Some("http") | Some("https") => {
    //             unimplemented!();
    //         }
    //         Some(_) | None => {
    //             error!(
    //                 "Invalid location please verify again the input location on the toml config"
    //             );
    //         }
    //     }
    // }

    // table.printstd();
    // pm.unload();

    let duration = start.elapsed();
    let minutes = duration.as_secs() / 60;
    let seconds = duration.as_secs() % 60;

    if minutes == 0 && seconds == 0 {
        debug!("Operation took less than 1 second.");
    } else {
        debug!(
            "Operation took {} minutes and {} seconds.",
            minutes, seconds
        );
    }

    Ok(())
}
