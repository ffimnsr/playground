use async_trait::async_trait;
use futures::stream::BoxStream;
use futures::{FutureExt, StreamExt};
use std::{
    collections::HashMap,
    result::Result,
    sync::{Arc, Mutex},
};

type City = String;
type Temperature = u64;

#[async_trait]
pub trait Api: Send + Sync + 'static {
    async fn fetch(&self) -> Result<HashMap<City, Temperature>, String>;
    async fn subscribe(&self) -> BoxStream<Result<(City, Temperature), String>>;
}

pub struct StreamCache {
    results: Arc<Mutex<HashMap<String, u64>>>,
}

impl StreamCache {
    pub fn new(api: impl Api) -> Self {
        let instance = Self {
            results: Arc::new(Mutex::new(HashMap::new())),
        };
        instance.update_in_background(api);
        instance
    }

    pub fn get(&self, key: &str) -> Option<u64> {
        let results = self.results.lock().expect("poisoned");
        results.get(key).copied()
    }

    pub fn update_in_background(&self, api: impl Api) {
        let api = Arc::new(api);
        let api_cl = api.clone();
        // TODO: need to improve using probably select_next_some and select_biased
        let int_results: Arc<Mutex<HashMap<String, u64>>> = Arc::new(Mutex::new(HashMap::new()));
        let int_results_cl = int_results.clone();

        let results = self.results.clone();
        tokio::spawn(async move {
            // Fetch initial data
            api.fetch()
                .map(|data| data.expect("Error fetching updates"))
                .map(|data| {
                    let mut results = results.lock().expect("poisoned");
                    data.into_iter().for_each(|(k, v)| {
                        println!("Got result: {k:?} {v:?}");
                        results.insert(k, v);
                    });
                })
                .map(|_| {
                    let mut results = results.lock().expect("poisoned");
                    let internal = int_results.lock().expect("poisoned");
                    internal.iter().for_each(|(k, v)| {
                        println!("Got result: {k:?} {v:?}");
                        results.insert(k.clone(), *v);
                    });
                })
                .await;
        });

        let results = self.results.clone();
        tokio::spawn(async move {
            // Subscribe to updates
            let mut stream = api_cl.subscribe().await;
            while let Some(result) = stream.next().await {
                println!("Got result: {result:?}");
                // TODO: need to improve as this was doing duplicate work
                result
                    .map(|(k, v)| {
                        let mut results = int_results_cl.lock().expect("poisoned");
                        results.insert(k.clone(), v);
                        (k, v)
                    })
                    .map(|(k, v)| {
                        let mut results = results.lock().expect("poisoned");
                        results.insert(k, v);
                    })
                    .expect("Error fetching subscription updates");
            }
        });
    }
}

#[cfg(test)]
mod tests {
    use std::time::Duration;
    use tokio::sync::Notify;
    use tokio::time;

    use futures::{future, stream::select, FutureExt, StreamExt};
    use maplit::hashmap;

    use super::*;

    #[derive(Default)]
    struct TestApi {
        signal: Arc<Notify>,
    }

    #[async_trait]
    impl Api for TestApi {
        async fn fetch(&self) -> Result<HashMap<City, Temperature>, String> {
            // fetch is slow an may get delayed until after we receive the first updates
            self.signal.notified().await;
            Ok(hashmap! {
                "Berlin".to_string() => 29,
                "Paris".to_string() => 31,
            })
        }
        async fn subscribe(&self) -> BoxStream<Result<(City, Temperature), String>> {
            let results = vec![
                Ok(("London".to_string(), 27)),
                Ok(("Paris".to_string(), 32)),
            ];
            select(
                futures::stream::iter(results),
                async {
                    self.signal.notify_one();
                    future::pending().await
                }
                .into_stream(),
            )
            .boxed()
        }
    }
    #[tokio::test]
    async fn works() {
        let cache = StreamCache::new(TestApi::default());

        // Allow cache to update
        time::sleep(Duration::from_millis(100)).await;

        assert_eq!(cache.get("Berlin"), Some(29));
        assert_eq!(cache.get("London"), Some(27));
        assert_eq!(cache.get("Paris"), Some(32));
    }
}
