#![recursion_limit = "1024"]

mod package_list;
mod package_details;

use wasm_bindgen::prelude::*;
use yew::prelude::*;
use yew::virtual_dom::VNode;
use yew_router::prelude::*;
use yew_router::switch::Permissive;
use wasm_logger::Config as LoggerConfig;
use wee_alloc::WeeAlloc;

use crate::package_list::PackageListModel;
use crate::package_details::{PackageDetailsModel, PackageDetailsRoute, Props as PackageDetailsProps};

#[global_allocator]
static ALLOC: WeeAlloc = WeeAlloc::INIT;

#[derive(Debug, Switch, Clone)]
pub enum AppRoute {
    #[to = "/package-list"]
    PackageList,
    #[to = "/package{*:inner}"]
    PackageDetails(PackageDetailsRoute),
    #[to = "/about"]
    About,
    #[to = "/settings"]
    Settings,
    #[to = "/page-not-found"]
    PageNotFound(Permissive<String>),
}

pub type Link = RouterAnchor<AppRoute>;
type AppRouter = Router<AppRoute>;

struct Model;

impl Component for Model {
    type Message = ();
    type Properties = ();

    fn create(_: Self::Properties, _link: ComponentLink<Self>) -> Self {
        Self
    }

    fn update(&mut self, _msg: Self::Message) -> ShouldRender {
        false
    }

    fn change(&mut self, _props: Self::Properties) -> ShouldRender {
        false
    }

    fn view(&self) -> VNode {
        html! {
            <div>
                <nav>
                    <div class="nav-wrapper">
                        <ul class="left hide-on-med-and-down">
                            <li><Link route=AppRoute::PackageList>{ "Package List" }</Link></li>
                            <li><Link route=AppRoute::Settings>{ "Settings" }</Link></li>
                            <li><Link route=AppRoute::PageNotFound(Permissive(Some("nope".to_string())))>{ "Dummy Link" }</Link></li>
                        </ul>
                    </div>
                </nav>
                <main>
                    <AppRouter
                        render = Router::render(|switch: AppRoute| {
                            match switch {
                                AppRoute::PackageList => html! { <PackageListModel /> },
                                AppRoute::PackageDetails(route) => {
                                    let route: PackageDetailsProps = route.into();
                                    html! { <PackageDetailsModel with route /> }
                                },
                                AppRoute::About => html! { "About" },
                                AppRoute::Settings => html! { "Settings" },
                                AppRoute::PageNotFound(Permissive(None)) => html! { "Page not found" },
                                AppRoute::PageNotFound(Permissive(Some(missed_route))) => html! { format!("Page '{}' not found", missed_route) },
                                _ => html! { "Unknown" },   
                            }
                        })
                        redirect = Router::redirect(|r: Route| {
                            AppRoute::PageNotFound(Permissive(Some(r.route)))
                        })
                    />
                </main>
            </div>
        }
    }
}

#[wasm_bindgen(start)]
pub fn run_app() {
    wasm_logger::init(LoggerConfig::default());
    App::<Model>::new().mount_to_body();
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
