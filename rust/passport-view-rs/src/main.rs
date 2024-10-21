use yew_router::prelude::*;
use yew::prelude::*;
use bounce::BounceRoot;
use crate::route::{switch, Route};
use crate::theme::ThemeProvider;

mod components;
mod home;
mod job_detail;
mod model;
mod markdown;
mod not_found;
mod route;
mod state;
mod theme;

#[function_component(App)]
pub fn app() -> Html {
    html! {
        <ThemeProvider>
            <BounceRoot>
                <BrowserRouter>
                    <Switch<Route> render={switch} />
                </BrowserRouter>
            </BounceRoot>
        </ThemeProvider>
    }
}

fn main() {
    yew::Renderer::<App>::new().render();
}
