use crate::errors::OHLCVDataError;
use crate::data_traits::*;

#[derive(Debug, Clone, PartialEq)]
pub struct OHLCVData {
    open: f64,
    high: f64,
    low: f64,
    close: f64,
    volume: f64,
}

impl OHLCVData {
    pub fn builder() -> OHLCVDataBuilder {
        OHLCVDataBuilder::new()
    }
}

impl Open for OHLCVData {
    fn open(&self) -> f64 {
        self.open
    }
}

impl High for OHLCVData {
    fn high(&self) -> f64 {
        self.high
    }
}

impl Low for OHLCVData {
    fn low(&self) -> f64 {
        self.low
    }
}

impl Close for OHLCVData {
    fn close(&self) -> f64 {
        self.close
    }
}

impl Volume for OHLCVData {
    fn volume(&self) -> f64 {
        self.volume
    }
}

#[derive(Debug, PartialEq)]
pub struct OHLCVDataBuilder {
    pub(self) open: Option<f64>,
    pub(self) high: Option<f64>,
    pub(self) low: Option<f64>,
    pub(self) close: Option<f64>,
    pub(self) volume: Option<f64>,
}

impl OHLCVDataBuilder {
    pub fn new() -> Self {
        Self {
            open: None,
            high: None,
            low: None,
            close: None,
            volume: None,
        }
    }

    pub fn open<T: Into<f64>>(mut self, val: T) -> Self {
        self.open = Some(val.into());
        self
    }

    pub fn high<T: Into<f64>>(mut self, val: T) -> Self {
        self.high = Some(val.into());
        self
    }

    pub fn low<T: Into<f64>>(mut self, val: T) -> Self {
        self.low = Some(val.into());
        self
    }

    pub fn volume<T: Into<f64>>(mut self, val: T) -> Self {
        self.volume = Some(val.into());
        self
    }

    pub fn close<T: Into<f64>>(mut self, val: T) -> Self {
        self.close = Some(val.into());
        self
    }

    pub fn build(self) -> Result<OHLCVData, OHLCVDataError> {
        if let Self {
            open: Some(open),
            high: Some(high),
            low: Some(low),
            close: Some(close),
            volume: Some(volume),
        } = self
        {
            if low <= open
                && low <= close
                && low <= high
                && high <= open
                && high <= close
                && volume >= 0.0f64
                && low >= 0.0f64
            {
                let item = OHLCVData {
                    open,
                    high,
                    low,
                    close,
                    volume,
                };

                Ok(item)
            } else {
                Err(OHLCVDataError::Invalid)
            }
        } else {
            Err(OHLCVDataError::Incomplete)
        }
    }
}
