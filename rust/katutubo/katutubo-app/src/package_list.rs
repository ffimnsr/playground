use yew::prelude::*;
use yew::format::Nothing;
use yew::virtual_dom::VNode;
use yew::services::fetch::Request;

use crate::{AppRoute, Link};
use crate::package_details::PackageDetailsRoute;

pub struct PackageListModel;

impl Component for PackageListModel {
    type Message = ();
    type Properties = ();

    fn create(_props: Self::Properties, _link: ComponentLink<Self>) -> Self {
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
            <div class="container">
                <table class="highlight">
                    <thead>
                        <tr>
                            <th>{ "Package Name" }</th>
                            <th>{ "Installed Version" }</th>
                            <th>{ "Latest Version" }</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><Link route=AppRoute::PackageDetails(PackageDetailsRoute::None)>{ "Sample App" }</Link></td>
                            <td>{ "2.0.0" }</td>
                            <td>{ "2.1.0" }</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        }
    }
}

impl PackageListModel {
    fn get_package_list() {
        let package_list_url = "https://raw.githubusercontent.com/ffimnsr/katutubo-package-repo/master/package-list.json";
        let req = Request::get(package_list_url)
            .body(Nothing)
            .expect("Could not execute the request");
    }
}