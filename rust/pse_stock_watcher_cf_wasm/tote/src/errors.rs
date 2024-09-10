use thiserror::Error;
#[derive(Error, Debug)]
pub enum CommonError {
    #[error("expected a valid argument")]
    InvalidArgument,
}

#[derive(Error, Debug)]
pub enum OHLCVDataError {
    #[error("expected a valid OHLCV input data")]
    Invalid,
    #[error("expected a complete OHLCV input data")]
    Incomplete,
    #[error("unknown data error")]
    Unknown,
}
