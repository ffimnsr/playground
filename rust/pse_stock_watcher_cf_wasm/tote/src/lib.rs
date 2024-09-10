use reqwest::header::{self, HeaderMap, HeaderValue};

pub mod errors;
pub mod indicators;
mod ohlcv_data;

pub use crate::ohlcv_data::OHLCVData;

pub mod data_traits {
    pub trait Reset {
        fn reset(&mut self);
    }

    pub trait Period {
        fn period(&self) -> usize;
    }

    pub trait Open {
        fn open(&self) -> f64;
    }

    pub trait Close {
        fn close(&self) -> f64;
    }

    pub trait High {
        fn high(&self) -> f64;
    }

    pub trait Low {
        fn low(&self) -> f64;
    }

    pub trait Volume {
        fn volume(&self) -> f64;
    }

    pub trait Next<T> {
        type Output;
        fn next(&mut self, input: T) -> Self::Output;
    }
}

fn construct_headers() -> HeaderMap {
    let mut headers = HeaderMap::new();
    headers.insert(header::REFERER, HeaderValue::from_static("http://www.pse.com.ph/stockMarket/home.html"));
    headers.insert("X-Requested-With", HeaderValue::from_static("XMLHttpRequest"));
    headers
}

pub async fn get_securities_and_indices_for_public() -> Result<(), reqwest::Error> {
    let client = reqwest::Client::builder()
        .default_headers(construct_headers())
        .build()?;

    let echo_json: serde_json::Value = client
        .get("http://www.pse.com.ph/stockMarket/home.html")
        .query(&[
            ("method", "getSecuritiesAndIndicesForPublic"),
            ("ajax", "true"),
        ])
        .send()
        .await?
        .json()
        .await?;

    println!("{:#?}", echo_json);

    Ok(())
}

pub async fn find_security_or_company() -> Result<(), reqwest::Error> {
    let client = reqwest::Client::builder()
        .default_headers(construct_headers())
        .build()?;

    let echo_json: serde_json::Value = client
        .get("http://www.pse.com.ph/stockMarket/home.html")
        .query(&[
            ("method", "findSecurityOrCompany"),
            ("ajax", "true"),
            ("start", "0"),
            ("limit", "1"),
            ("query", "sm"),
        ])
        .send()
        .await?
        .json()
        .await?;

    println!("{:#?}", echo_json);

    Ok(())
}

pub async fn company_info() -> Result<(), reqwest::Error> {
    let client = reqwest::Client::builder()
        .default_headers(construct_headers())
        .build()?;

    let echo_json: serde_json::Value = client
        .get("http://www.pse.com.ph/stockMarket/companyInfo.html")
        .query(&[
            ("method", "fetchHeaderData"),
            ("ajax", "true"),
            ("company", "599"),
            ("security", "520"),
        ])
        .send()
        .await?
        .json()
        .await?;

    println!("{:#?}", echo_json);

    Ok(())
}

pub async fn company_info_historical_data() -> Result<(), reqwest::Error> {
    let client = reqwest::Client::builder()
        .default_headers(construct_headers())
        .build()?;

    let echo_json: serde_json::Value = client
        .post("http://www.pse.com.ph/stockMarket/companyInfoHistoricalData.html")
        .query(&[
            ("method", "getRecentSecurityQuoteData"),
            ("ajax", "true"),
            ("security", "520"),
        ])
        .send()
        .await?
        .json()
        .await?;

    println!("{:#?}", echo_json);

    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
