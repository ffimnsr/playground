pub struct Stocks {
    pub data: Vec<StockC>,
    pub timestamp: chrono::Datetime,
}

pub struct StockC {
    pub name: String,
    pub price: Price,
    pub perc_change_close: f64,
    pub volume: i64,
    pub symbol: String,
}

pub struct Currency {
    pub name: String,
}

pub struct Price {
    pub currency: Currency,
    pub amount: f64,
}
