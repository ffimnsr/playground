use yew_router::prelude::*;
use yew::prelude::*;
use route::{switch, Route};

mod components;
mod home;
mod model;
mod not_found;
mod route;

#[function_component(App)]
pub fn app() -> Html {
    html! {
        <BrowserRouter>
            <Switch<Route> render={switch} />
        </BrowserRouter>
    }
}

fn main() {
    yew::Renderer::<App>::new().render();
}
