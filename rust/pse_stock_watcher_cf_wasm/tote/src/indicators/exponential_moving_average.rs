use std::fmt;

use crate::errors::CommonError;
use crate::data_traits::{Close, Next, Period, Reset};

#[derive(Debug, Clone)]
pub struct ExponentialMovingAverage {
    period: usize,
    k: f64,
    current: f64,
    is_new: bool,
}

impl ExponentialMovingAverage {
    pub fn new(period: usize) -> Result<Self, CommonError> {
        match period {
            0 => Err(CommonError::InvalidArgument),
            _ => Ok(Self {
                period,
                k: 2.0 / (period + 1) as f64,
                current: 0.0,
                is_new: true,
            }),
        }
    }
}

impl Period for ExponentialMovingAverage {
    fn period(&self) -> usize {
        self.period
    }
}

impl Next<f64> for ExponentialMovingAverage {
    type Output = f64;

    fn next(&mut self, input: f64) -> Self::Output {
        if self.is_new {
            self.is_new = false;
            self.current = input;
        } else {
            self.current = self.k * input + (1.0 - self.k) * self.current;
        }
        self.current
    }
}

impl<T: Close> Next<&T> for ExponentialMovingAverage {
    type Output = f64;

    fn next(&mut self, input: &T) -> Self::Output {
        self.next(input.close())
    }
}

impl Reset for ExponentialMovingAverage {
    fn reset(&mut self) {
        self.current = 0.0;
        self.is_new = true;
    }
}

impl Default for ExponentialMovingAverage {
    fn default() -> Self {
        Self::new(9).unwrap()
    }
}

impl fmt::Display for ExponentialMovingAverage {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "EMA({})", self.period)
    }
}
