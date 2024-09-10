use std::error::Error;

pub(crate) type GenericError = Box<dyn Error + Send + Sync>;
