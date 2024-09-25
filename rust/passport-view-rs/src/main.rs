use yew::prelude::*;
use gloo_net::http::Request;
use model::{Job, JobsList};

mod model;

#[function_component(App)]
pub fn app() -> Html {
    // let counter = use_state(|| 0);
    // let onclick = {
    //     let counter = counter.clone();
    //     move |_| {
    //         let value = *counter + 1;
    //         counter.set(value);
    //     }
    // };

    let jobs = use_state(|| vec![]);
    {
        let jobs = jobs.clone();
        use_effect_with((), move |_| {
            let jobs = jobs.clone();
            wasm_bindgen_futures::spawn_local(async move {
                let fetched_jobs: Vec<Job> = Request::get("http://localhost:5000/jobs")
                    .send()
                    .await
                    .unwrap()
                    .json()
                    .await
                    .unwrap();

                jobs.set(fetched_jobs);
            });
            || ()
        });
    }

    html! {
        <div>
            <JobsList jobs={(*jobs).clone()} />
        </div>
    }
}

fn main() {
    yew::Renderer::<App>::new().render();
}
