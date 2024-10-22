use yew_router::prelude::*;
use yew::prelude::*;
use crate::home::Home;
use crate::job_detail::JobDetail;
use crate::gig_detail::GigDetail;
use crate::gig_landing::GigLanding;
use crate::not_found::NotFound;

#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Home,
    #[at("/jobs/*")]
    Jobs,
    #[at("/gigs")]
    GigLanding,
    #[at("/gigs/*")]
    Gigs,
    #[not_found]
    #[at("/404")]
    NotFound,
}

#[derive(Clone, Routable, PartialEq)]
pub enum JobsRoute {
    #[at("/jobs/:job_id")]
    JobDetail { job_id: String },
    #[not_found]
    #[at("/jobs/404")]
    NotFound,    
}

#[derive(Clone, Routable, PartialEq)]
pub enum GigsRoute {
    #[at("/gigs/:gig_id")]
    GigDetail { gig_id: String },
    #[not_found]
    #[at("/gigs/404")]
    NotFound,    
}

pub fn switch(routes: Route) -> Html {
    match routes {
        Route::Home => html! { <Home /> },
        Route::Jobs => html! { <Switch<JobsRoute> render={switch_jobs} /> },
        Route::GigLanding => html! { <GigLanding /> },
        Route::Gigs => html! { <Switch<GigsRoute> render={switch_gigs} /> },
        Route::NotFound => html! { <NotFound /> },
    }
}

pub fn switch_jobs(routes: JobsRoute) -> Html {
    match routes {
        JobsRoute::JobDetail { job_id } => html! { <JobDetail {job_id} /> },
        JobsRoute::NotFound => html! { <Redirect<Route> to={Route::NotFound}/> },
    }
}

pub fn switch_gigs(routes: GigsRoute) -> Html {
    match routes {
        GigsRoute::GigDetail { gig_id } => html! { <GigDetail {gig_id} /> },
        GigsRoute::NotFound => html! { <Redirect<Route> to={Route::NotFound}/> },
    }
}
