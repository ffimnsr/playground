
#[tokio::main]
async fn main() {
    tote::company_info_historical_data().await.unwrap();
    println!("I'm using the library");
}