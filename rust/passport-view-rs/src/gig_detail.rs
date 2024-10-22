use yew::prelude::*;
use crate::components::{Footer, Header, JobDetailView, JobDetailViewLoading};
use crate::theme::{Theme, ThemeContext};

#[derive(Debug, PartialEq, Properties)]
pub struct GigDetailProps {
    pub gig_id: String,
}

#[function_component(GigDetail)]
pub fn job_detail(props: &GigDetailProps) -> Html {
    let theme_ctx = use_context::<ThemeContext>().expect("no theme context found");
    let dark_mode_active = theme_ctx.is_dark;
    let dark_mode_active_class = if !dark_mode_active { "" } else { "dark" };
    let toggle_dark_mode = {
        Callback::from(move |_: MouseEvent| {
            theme_ctx.set(Theme {
                is_dark: !theme_ctx.is_dark,
            });
        })
    };

    let job_id = props.gig_id.clone();
    let fallback = html! {<JobDetailViewLoading />};

    html! {
        <div class={classes!("flex", "flex-col", "min-h-screen", dark_mode_active_class)}>
            <Header is_dark={dark_mode_active} onclick_dark_mode_button={toggle_dark_mode} />
            <div class="bg-gray-100 dark:invert flex-grow">
                <div class="mx-auto max-w-7xl py-6 sm:px-6 lg:px-8">
                    <div class="mx-auto max-w-none">
                        <Suspense {fallback}>
                            <JobDetailView {job_id} />
                        </Suspense>
                    </div>
                </div>
            </div>
            <Footer/>
        </div>
    }
}
