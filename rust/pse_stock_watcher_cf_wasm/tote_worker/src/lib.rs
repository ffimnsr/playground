extern crate js_sys;

use cfg_if::cfg_if;
use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{Request, RequestInit, Response};

#[allow(unused_imports)]
use log::{info, Level};

mod utils;

cfg_if! {
    // When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
    // allocator.
    if #[cfg(feature = "wee_alloc")] {
        extern crate wee_alloc;
        #[global_allocator]
        static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;
    }
}

cfg_if! {
    if #[cfg(feature = "console_log")] {
        fn init_log() {
            console_log::init_with_level(Level::Trace).expect("error initializing log");
        }
    } else {
        fn init_log() {}
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Stock {
    pub total_volume: String,
    pub indicator: String,
    pub perc_change_close: String,
    pub last_traded_price: String,
    pub security_alias: String,
    #[serde(skip)]
    pub indicator_img: String,
    pub security_symbol: String,
}

pub fn worker_global_scope() -> Option<web_sys::ServiceWorkerGlobalScope> {
    #[allow(unused_unsafe)]
    unsafe {
        js_sys::global().dyn_into::<web_sys::ServiceWorkerGlobalScope>().ok()
    }
}

pub async fn get_securities_and_indices_for_public() -> Result<JsValue, JsValue> {
    std::panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_log();

    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(
        "https://cors-anywhere.herokuapp.com/https://www.pse.com.ph/stockMarket/home.html?method=getSecuritiesAndIndicesForPublic&ajax=true",
        &opts
    )?;

    request.headers().set("Origin", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("Referer", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("X-Requested-With", "XMLHttpRequest")?;

    let global = worker_global_scope().unwrap();
    let resp_value = JsFuture::from(global.fetch_with_request(&request)).await?;

    assert!(resp_value.is_instance_of::<Response>());
    let resp: Response = resp_value.dyn_into().unwrap();
    let json = JsFuture::from(resp.json()?).await?;

    Ok(json)
}

pub async fn find_security_or_company() -> Result<JsValue, JsValue> {
    std::panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_log();

    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(
        "https://cors-anywhere.herokuapp.com/https://www.pse.com.ph/stockMarket/home.html?method=findSecurityOrCompany&ajax=true&start=0&limit=1&query=sm",
        &opts
    )?;

    request.headers().set("Origin", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("Referer", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("X-Requested-With", "XMLHttpRequest")?;

    let global = worker_global_scope().unwrap();
    let resp_value = JsFuture::from(global.fetch_with_request(&request)).await?;

    assert!(resp_value.is_instance_of::<Response>());
    let resp: Response = resp_value.dyn_into().unwrap();
    let json = JsFuture::from(resp.json()?).await?;

    Ok(json)
}

pub async fn company_info() -> Result<JsValue, JsValue> {
    std::panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_log();

    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(
        "https://cors-anywhere.herokuapp.com/https://www.pse.com.ph/stockMarket/companyInfo.html?method=fetchHeaderData&ajax=true&company=599&security=520",
        &opts
    )?;

    request.headers().set("Origin", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("Referer", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("X-Requested-With", "XMLHttpRequest")?;

    let global = worker_global_scope().unwrap();
    let resp_value = JsFuture::from(global.fetch_with_request(&request)).await?;

    assert!(resp_value.is_instance_of::<Response>());
    let resp: Response = resp_value.dyn_into().unwrap();
    let json = JsFuture::from(resp.json()?).await?;

    Ok(json)
}

pub async fn company_info_historical_data() -> Result<JsValue, JsValue> {
    std::panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_log();

    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(
        "https://cors-anywhere.herokuapp.com/https://www.pse.com.ph/stockMarket/companyInfoHistoricalData.html?method=getRecentSecurityQuoteData&ajax=true&security=520",
        &opts
    )?;

    request.headers().set("Origin", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("Referer", "https://www.pse.com.ph/stockMarket/home.html")?;
    request.headers().set("X-Requested-With", "XMLHttpRequest")?;

    let global = worker_global_scope().unwrap();
    let resp_value = JsFuture::from(global.fetch_with_request(&request)).await?;

    assert!(resp_value.is_instance_of::<Response>());
    let resp: Response = resp_value.dyn_into().unwrap();
    let json = JsFuture::from(resp.json()?).await?;

    Ok(json)
}

#[wasm_bindgen]
pub async fn get_all_stocks() -> Result<JsValue, JsValue> {
    let json = get_securities_and_indices_for_public().await?;
    let stocks: Vec<Stock> = json.into_serde().unwrap();
    Ok(JsValue::from_serde(&stocks).unwrap())

}

#[wasm_bindgen]
pub async fn get_stock(symbol: String) -> Result<JsValue, JsValue> {
    let json = get_securities_and_indices_for_public().await?;

    let raw_stocks: Vec<Stock> = json.into_serde().unwrap();
    let mut res_stocks: Vec<Stock> = Vec::new();
    for stock in raw_stocks.iter() {
        if stock.security_symbol.to_lowercase() == symbol.to_lowercase() {
            res_stocks.push(stock.clone());
        }
    }

    Ok(JsValue::from_serde(&res_stocks).unwrap())
}

#[wasm_bindgen]
pub async fn get_stock_by_date(_symbol: String,_timestamp: String) -> Result<JsValue, JsValue> {
    // find_symbol_and_trading_date
    get_securities_and_indices_for_public().await
}

#[wasm_bindgen]
pub async fn archive() -> Result<JsValue, JsValue> {
    // save all stocks
    get_securities_and_indices_for_public().await
}

#[wasm_bindgen]
pub async fn test() -> Result<JsValue, JsValue> {
    std::panic::set_hook(Box::new(console_error_panic_hook::hook));
    init_log();

    let mut opts = RequestInit::new();
    opts.method("GET");

    let request = Request::new_with_str_and_init(
        "https://httpbin.org/get",
        &opts
    )?;

    let global = worker_global_scope().unwrap();
    let resp_value = JsFuture::from(global.fetch_with_request(&request)).await?;

    assert!(resp_value.is_instance_of::<Response>());
    let resp: Response = resp_value.dyn_into().unwrap();
    let json = JsFuture::from(resp.json()?).await?;

    Ok(json)
}