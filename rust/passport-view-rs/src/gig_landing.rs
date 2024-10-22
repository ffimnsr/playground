use yew::prelude::*;
use crate::components::{Footer, Header, GigsViewLoading, GigsView};
use crate::theme::{Theme, ThemeContext};

#[function_component(GigLanding)]
pub fn gig_landing() -> Html {
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

    let fallback = html! {<GigsViewLoading />};
    html! {
        <div class={classes!("flex", "flex-col", "min-h-screen", dark_mode_active_class)}>
            <div id="modal_host"></div>
            <Header is_dark={dark_mode_active} onclick_dark_mode_button={toggle_dark_mode} />
            <div class="bg-gray-100 dark:invert flex-grow">
                <div class="mx-auto max-w-7xl py-6 sm:px-6 lg:px-8">
                    <div class="mx-auto max-w-none">
                        <Suspense {fallback}>
                            <GigsView />
                        </Suspense>
                    </div>
                </div>
            </div>
            <Footer/>
        </div>
    }
}
