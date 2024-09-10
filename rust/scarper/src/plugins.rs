use libloading::{Library, Symbol};
use log::{debug, trace};
use std::any::Any;
use std::ffi::OsStr;

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

pub trait Plugin: Any + Send + Sync {
    fn name(&self) -> &'static str;
    fn on_plugin_load(&self);
    fn on_plugin_unload(&self);
    fn get_package_version(&self) -> &'static str;
}

#[derive(Default)]
pub struct PluginManager {
    plugins: Vec<Box<dyn Plugin>>,
    loaded_libraries: Vec<Library>,
}

impl PluginManager {
    pub fn new() -> Self {
        PluginManager {
            plugins: Vec::new(),
            loaded_libraries: Vec::new(),
        }
    }

    pub fn load_plugin<P: AsRef<OsStr>>(
        &mut self,
        filename: P,
    ) -> Result<(), Box<dyn std::error::Error>> {
        type PluginCreate = unsafe fn() -> *mut dyn Plugin;

        let lib = Library::new(filename.as_ref()).unwrap();

        self.loaded_libraries.push(lib);

        let lib = self.loaded_libraries.last().unwrap();

        unsafe {
            let constructor: Symbol<PluginCreate> = lib.get(b"plug_create").unwrap();
            let boxed_raw = constructor();
            let plugin = Box::from_raw(boxed_raw);

            debug!("Loaded plugins: {}", plugin.name());

            plugin.on_plugin_load();
            self.plugins.push(plugin);
        }

        Ok(())
    }

    pub fn get_package_version(&mut self, plugin: &str) -> &str {
        debug!("Getting package version");

        let plugin_name = format!("plug_{}", plugin);
        match self.plugins.iter().find(|p| p.name() == plugin_name) {
            Some(p) => p.get_package_version(),
            None => "None",
        }
    }

    pub fn unload(&mut self) {
        debug!("Unloading plugins");

        for plugin in self.plugins.drain(..) {
            trace!("Running clean up for {:?}", plugin.name());
            plugin.on_plugin_unload();
        }

        for lib in self.loaded_libraries.drain(..) {
            drop(lib);
        }
    }
}

impl Drop for PluginManager {
    fn drop(&mut self) {
        if !self.plugins.is_empty() || !self.loaded_libraries.is_empty() {
            self.unload();
        }
    }
}
