use yew::prelude::*;
use yew::Properties;
use yew::virtual_dom::VNode;
use yew_router::prelude::*;
use yew_router::agent::RouteRequest;

#[derive(Debug, Switch, Clone)]
pub enum PackageDetailsRoute {
    #[to = "/{package_id}/details"]
    Details(String),
    #[to = "/"]
    None,
}

#[derive(Debug, Properties, Clone)]
pub struct Props {
    pub package_id: Option<String>,
}

impl Into<Props> for PackageDetailsRoute {
    fn into(self) -> Props {
        match self {
            PackageDetailsRoute::None => Props {
                package_id: None,
            },
            PackageDetailsRoute::Details(package_id) => Props {
                package_id: Some(package_id),
            }
        }
    }
}

pub struct PackageDetailsModel {
    props: Props,
    router: RouteAgentBridge,
}

pub enum Msg {
    Navigate(Vec<Msg>),
    NoOp,
}

impl Component for PackageDetailsModel {
    type Message = Msg;
    type Properties = Props;

    fn create(props: Self::Properties, link: ComponentLink<Self>) -> Self {
        let callback = link.callback(|_| Msg::NoOp);
        let router = RouteAgentBridge::new(callback);

        Self {
            props,
            router,
        }
    }

    fn update(&mut self, msg: Self::Message) -> ShouldRender {
        match msg {
            Msg::NoOp => false,
            Msg::Navigate(msgs) => {
                for msg in msgs {
                    self.update(msg);
                }

                let route_string = "/package".to_string();
                let route_string = match &self.props.package_id {
                    Some(package_id) => route_string + "#" + &package_id,
                    None => route_string,
                };

                let route = Route::from(route_string);

                self.router.send(RouteRequest::ChangeRouteNoBroadcast(route));
                true
            }
        }
    }

    fn change(&mut self, props: Self::Properties) -> ShouldRender {
        self.props = props;
        true
    }

    fn view(&self) -> VNode {
        html! {
            <div class="container">
                { self.display_package_id() }
            </div>
        }
    }
}

impl PackageDetailsModel {
    fn display_package_id(&self) -> String {
        if let Some(package_id) = self.props.package_id.clone() {
            format!("Package Id: {}", package_id)
        } else {
            "Package Id: None".to_string()
        }
    }
}
