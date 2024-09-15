use indoc::formatdoc;
use log::{debug, error};
use rusqlite::Connection;
use serde::Deserialize;
use std::error::Error;
use std::ffi::OsStr;
use std::fs::File;
use std::io::prelude::*;

#[macro_export]
macro_rules! declare_plugin {
    ($plugin_type:ty, $constructor:path) => {
        #[no_mangle]
        pub unsafe fn plug_create() -> *mut dyn $crate::Plugin {
            let constructor: fn() -> $plugin_type = $constructor;

            let object = constructor();
            let boxed: Box<dyn $crate::Plugin> = Box::new(object);

            Box::into_raw(boxed)
        }
    };
}

#[derive(Deserialize)]
struct PluginContainer {
    plugin: Plugin,
}

#[derive(Debug, Deserialize, Clone, Default)]
pub struct Plugin {
    name: String,
    alias: Vec<String>,
    location: String,
    binary: Option<String>,
}

impl Plugin {
    pub fn new(name: &str, alias: &[&str], location: &str, binary: Option<&str>) -> Self {
        Self {
            name: name.to_string(),
            alias: alias.to_vec().iter().map(|s| s.to_string()).collect(),
            location: location.to_string(),
            binary: None,
        }
    }

    pub fn new_with_binary(name: &str, alias: &[&str], location: &str, binary: &str) -> Self {
        Self {
            name: name.to_string(),
            alias: alias.to_vec().iter().map(|s| s.to_string()).collect(),
            location: location.to_string(),
            binary: Some(binary.to_string()),
        }
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn alias(&self) -> &Vec<String> {
        &self.alias
    }
}

pub trait PluginManagerBase {
    fn load_plugin<P>(&mut self, filename: P) -> Result<(), Box<dyn Error>>
    where
        P: AsRef<OsStr>;

    fn get_plugin_info<P>(&mut self, plugin_name: P) -> Result<Box<Plugin>, Box<dyn Error>>
    where
        P: AsRef<OsStr>;

    fn unload(&mut self);
    fn count(&self) -> usize;
}

#[derive(Default)]
pub struct PluginManager {
    plugins: Vec<Plugin>,
    conn: Option<Connection>,
}

impl PluginManager {
    pub fn new() -> Self {
        let conn = Connection::open("./data.db3").ok();
        conn.as_ref()
            .expect("Failed to open connection")
            .execute(
                formatdoc!(
                    "
                    CREATE TABLE IF NOT EXISTS plugins (
                        id INTEGER PRIMARY KEY,
                        name VARCHAR (128) NOT NULL UNIQUE,
                        alias STRING NOT NULL,
                        location TEXT NOT NULL,
                        binary TEXT
                    )
                    "
                )
                .as_str(),
                (),
            )
            .expect("Failed to create table");

        Self {
            plugins: Vec::new(),
            conn,
        }
    }
}

impl PluginManagerBase for PluginManager {
    fn load_plugin<P>(&mut self, filename: P) -> Result<(), Box<dyn Error>>
    where
        P: AsRef<OsStr>,
    {
        debug!("Loading plugin");
        let plugin_content = parse(
            filename
                .as_ref()
                .to_str()
                .ok_or("Failed to convert path to string")?,
        );

        debug!("Plugin content: {plugin_content:?}");
        debug!("Check {}", &plugin_content.location.as_str());

        self.conn
            .as_ref()
            .ok_or("Failed to open connection")?
            .execute(
            "INSERT INTO plugins (name, alias, location, binary) VALUES (?1, ?2, ?3, ?4)",
            (
                &plugin_content.name.as_str(),
                &plugin_content.alias.join(",").as_str(),
                &plugin_content.location.as_str(),
                &plugin_content
                    .binary
                    .as_ref()
                    .unwrap_or(&"".to_string())
                    .as_str(),
            ),
        )?;

        self.plugins.push(plugin_content);
        Ok(())
    }

    fn get_plugin_info<P>(&mut self, plugin_name: P) -> Result<Box<Plugin>, Box<dyn Error>>
    where
        P: AsRef<OsStr>,
    {
        debug!("Getting plugin info");
        let plugin = self
            .conn
            .as_ref()
            .ok_or("Failed to open connection")?
            .query_row(
                "SELECT name, alias, location, binary FROM plugins WHERE name = ?1",
                [plugin_name.as_ref().to_str().unwrap()],
                |row| {
                    Ok(Plugin {
                        name: row.get(0)?,
                        alias: row
                            .get::<usize, String>(1)?
                            .split(",")
                            .map(|s| s.to_string())
                            .collect(),
                        location: row.get::<usize, String>(2)?,
                        binary: row.get(3)?,
                    })
                },
            )?;

        debug!("Plugin {plugin:?}");
        Ok(Box::from(plugin))
    }

    fn unload(&mut self) {
        debug!("Unloading plugins");
        self.plugins.clear();
    }

    fn count(&self)  -> usize {
        self.plugins.len()
    }
}

pub fn parse(path: &str) -> Plugin {
    let mut config = String::new();
    let mut file = match File::open(&path) {
        Ok(file) => file,
        Err(_) => {
            return Plugin::default();
        }
    };

    file.read_to_string(&mut config)
        .unwrap_or_else(|err| panic!("Error while reading config: [{:#?}]", err));

    debug!("Parsing config: [{config:#?}]");
    match toml::from_str::<PluginContainer>(&config) {
        Ok(t) => t.plugin,
        Err(err) => panic!("Error while deserializing config: [{:#?}]", err),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        let plugin = parse("plugins/ripgrep.toml");
        assert_eq!(plugin.name, "ripgrep");
        assert_eq!(plugin.alias, vec!["rg", "ripgrep"]);
        assert_eq!(plugin.location, "github:BurntSushi/ripgrep");
        assert_eq!(plugin.binary, Some("rg".to_string()));
    }
}
