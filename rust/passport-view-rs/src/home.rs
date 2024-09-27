use yew::prelude::*;
use crate::components::{JobsView, JobsViewLoading};

#[function_component(Home)]
pub fn home() -> Html {
    let fallback = html! {<JobsViewLoading />};
    html! {
        <div class="h-screen bg-gray-100">
            <div class="mx-auto max-w-7xl py-6 sm:px-6 lg:px-8">
                <div class="mx-auto max-w-none">
                    <Suspense {fallback}>
                        <JobsView />
                    </Suspense>
                </div>
            </div>
        </div>
    }
}