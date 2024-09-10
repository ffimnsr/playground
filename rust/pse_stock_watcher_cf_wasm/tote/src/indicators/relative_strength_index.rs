use std::fmt;

use crate::errors::CommonError;
use crate::data_traits::{Close, Next, Period, Reset};

use super::ExponentialMovingAverage as Ema;

#[derive(Debug, Clone)]
pub struct RelativeStrengthIndex {
    period: usize,
    up_ema_indicator: Ema,
    down_ema_indicator: Ema,
    prev_val: f64,
    is_new: bool,
}

impl RelativeStrengthIndex {
    pub fn new(period: usize) -> Result<Self, CommonError> {
        match period {
            0 => Err(CommonError::InvalidArgument),
            _ => Ok(Self {
                period,
                up_ema_indicator: Ema::new(period)?,
                down_ema_indicator: Ema::new(period)?,
                prev_val: 0.0,
                is_new: true,
            }),
        }
    }
}

impl Next<f64> for RelativeStrengthIndex {
    type Output = f64;

    fn next(&mut self, input: f64) -> Self::Output {
        let mut up = 0.0;
        let mut down = 0.0;

        if self.is_new {
            self.is_new = false;
            up = 0.1;
            down = 0.1;
        } else {
            if input > self.prev_val {
                up = input - self.prev_val;
            } else {
                down = self.prev_val - input;
            }
        }
        
        self.prev_val = input;
        let up_ema = self.up_ema_indicator.next(up);
        let down_ema = self.down_ema_indicator.next(down);
        let result = 100.0 * up_ema / (up_ema + down_ema);
        result
    }
}

impl<T: Close> Next<&T> for RelativeStrengthIndex {
    type Output = f64;

    fn next(&mut self, input: &T) -> Self::Output {
        self.next(input.close())
    }
}

impl Period for RelativeStrengthIndex {
    fn period(&self) -> usize {
        self.period
    }
}

impl Reset for RelativeStrengthIndex {
    fn reset(&mut self) {
        self.up_ema_indicator.reset();
        self.down_ema_indicator.reset();
        self.prev_val = 0.0;
        self.is_new = true;
    }
}

impl Default for RelativeStrengthIndex {
    fn default() -> Self {
        Self::new(14).unwrap()
    }
}

impl fmt::Display for RelativeStrengthIndex {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "RSI({})", self.period)
    }
}
