use yew_router::prelude::*;
use yew::prelude::*;
use crate::home::Home;
use crate::job_detail::JobDetail;
use crate::not_found::NotFound;

#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Home,
    #[at("/jobs/*")]
    Jobs,
    #[not_found]
    #[at("/404")]
    NotFound,
}

#[derive(Clone, Routable, PartialEq)]
pub enum JobsRoute {
    #[at("/jobs/:job_id")]
    JobDetail { job_id: i32 },
    #[not_found]
    #[at("/jobs/404")]
    NotFound,    
}

pub fn switch(routes: Route) -> Html {
    match routes {
        Route::Home => html! { <Home /> },
        Route::Jobs => html! { <Switch<JobsRoute> render={switch_jobs} /> },
        Route::NotFound => html! { <NotFound /> },
    }
}

pub fn switch_jobs(routes: JobsRoute) -> Html {
    match routes {
        JobsRoute::JobDetail { job_id } => html! { <JobDetail {job_id} /> },
        JobsRoute::NotFound => html! { <Redirect<Route> to={Route::NotFound}/> },
    }
}
