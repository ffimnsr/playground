use yew_router::prelude::*;
use yew::prelude::*;
use crate::route::{switch, Route};
use crate::theme::ThemeProvider;

mod components;
mod home;
mod job_detail;
mod model;
mod not_found;
mod route;
mod theme;

#[function_component(App)]
pub fn app() -> Html {
    html! {
        <ThemeProvider>
            <BrowserRouter>
                <Switch<Route> render={switch} />
            </BrowserRouter>
        </ThemeProvider>
    }
}

fn main() {
    yew::Renderer::<App>::new().render();
}
