use chrono::DateTime;
use gloo_net::http::Request;
use serde::Deserialize;
use yew::{prelude::*, suspense::use_future};
use yew_router::prelude::*;
use bounce::prelude::*;
use crate::model::*;
use crate::markdown;
use crate::route::{Route, JobsRoute};
use crate::state::State;
use super::Modal;

const BACKEND: Option<&str> = option_env!("BACKEND");

#[function_component(GigsViewLoading)]
pub fn gigs_view_loading() -> Html {
    let items = (1..=4).into_iter().map(|_| html! {
        <li>
            <a href="#" class="block hover:bg-gray-50">
                <div class="px-4 py-4 sm:px-6">
                    <div class="flex items-center justify-between">
                        <div class="truncate text-sm font-medium text-indigo-600 h-5 w-64 rounded bg-slate-700"></div>
                        <div class="ml-2 flex flex-shrink-0 h-5 w-24 rounded bg-slate-700"></div>
                    </div>
                    <div class="mt-2 flex justify-between">
                        <div class="sm:flex">
                            <div class="flex items-center text-sm text-gray-500 h-5 w-28 rounded bg-slate-700"></div>
                        </div>
                        <div class="ml-2 flex items-center text-sm text-gray-500 h-5 w-20 rounded bg-slate-700"></div>
                    </div>
                </div>
            </a>
        </li>
    }).collect::<Vec<_>>();

    html! {
        <div class="overflow-hidden bg-white sm:rounded-lg sm:shadow">
            <GigsViewHeading />
            <ul role="list" class="animate-pulse divide-y divide-gray-200">
                {for items}
            </ul>
        </div>
    }
}

#[function_component(GigsViewHeading)]
pub fn gigs_view_heading() -> Html {
    let modal_show = use_state(|| false);
    let toggle_modal_show = {
        let modal_show = modal_show.clone();
        Callback::from(move |_: MouseEvent| modal_show.set(!*modal_show))
    };

    html! {
        <div class="border-b border-gray-200 bg-white px-4 py-5 sm:px-6">
            <div class="-ml-4 -mt-4 flex flex-wrap items-center justify-between sm:flex-nowrap">
                <div class="ml-4 mt-4">
                    <h3 class="text-base font-semibold leading-6 text-gray-900">{"Gig Postings"}</h3>
                    <p class="mt-1 text-sm text-gray-500">
                        {"Find your next remote career opportunity with us!"}
                    </p>
                </div>
                <div class="ml-4 mt-4 flex-shrink-0">
                    <button onclick={toggle_modal_show.clone()} type="button" class="relative inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                        {"Search Gig"}
                    </button>
                    // if *modal_show {
                    //     <JobsSearchModal onclick_modal_show_button={toggle_modal_show} />
                    // }
                </div>
            </div>
        </div>
    }
}

#[function_component(GigsView)]
pub fn gigs_view() -> HtmlResult {
    let gstate = use_atom::<State>();
    
    // let jobs = use_future(|| async {
    //     let base_url = BACKEND.expect("BACKEND environment variable not set");
    //     let url: String = format!("{base_url}/jobs",);
    //     Request::get(&url)
    //         .send()
    //         .await?
    //         .json::<JobContainer>()
    //         .await
    // })?;

    // {
    //     let work_functions = use_future(|| async {
    //         let base_url = BACKEND.expect("BACKEND environment variable not set");
    //         let url: String = format!("{base_url}/work/functions",);
    //         Request::get(&url)
    //             .send()
    //             .await?
    //             .json::<WorkFunctionsContainer>()
    //             .await
    //     })?;
    
    //     let work_industries = use_future(|| async {
    //         let base_url = BACKEND.expect("BACKEND environment variable not set");
    //         let url: String = format!("{base_url}/work/industries",);
    //         Request::get(&url)
    //             .send()
    //             .await?
    //             .json::<WorkIndustriesContainer>()
    //             .await
    //     })?;

    //     gstate.set(State {
    //         work_functions: work_functions
    //             .as_ref()
    //             .unwrap_or(&WorkFunctionsContainer::default())
    //             .work_functions
    //             .clone(),
    //         work_industries: work_industries
    //             .as_ref()
    //             .unwrap_or(&WorkIndustriesContainer::default())
    //             .work_industries
    //             .clone(),
    //     });
    // }

    // let jobs = jobs.as_ref().ok();
    // let jobs = jobs
    //     .unwrap_or(&JobContainer { jobs: vec![] })
    //     .jobs
    //     .clone();

    Ok(html! {
        <div class="overflow-hidden bg-white sm:rounded-lg sm:shadow">
            <GigsViewHeading />
            <GigsList gigs={vec![]} />
        </div>
    })
}

#[derive(PartialEq, Properties)]
struct GigsListProps {
    pub gigs: Jobs,
}

#[function_component(GigsList)]
fn gigs_list(GigsListProps { gigs }: &GigsListProps) -> Html {
    let state = use_atom_value::<State>();
    let gigs_len = gigs.len();
    // let posts = jobs.iter().map(|job| html! {
    //     <li key={job.id.clone()}>
    //         <Link<JobsRoute> to={JobsRoute::JobDetail { job_id: job.id.clone() }}>
    //             <div class="px-4 py-4 sm:px-6">
    //                 <div class="flex items-center justify-between">
    //                     <div class="truncate text-sm font-medium text-indigo-600">{title_case(&job.title.clone())}</div>
    //                     <div class="ml-2 flex flex-shrink-0">
    //                         <span class="inline-flex items-center rounded-full bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
    //                             {realize_contract_type(job.work_contract_type.clone())}
    //                         </span>
    //                     </div>
    //                 </div>
    //                 <div class="mt-2 flex justify-between">
    //                     <div class="sm:flex">
    //                         <div class="flex items-center text-sm text-gray-500">
    //                             <svg class="mr-1.5 h-4 w-4 flex-shrink-0 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
    //                                 <path d="M7 8a3 3 0 100-6 3 3 0 000 6zM14.5 9a2.5 2.5 0 100-5 2.5 2.5 0 000 5zM1.615 16.428a1.224 1.224 0 01-.569-1.175 6.002 6.002 0 0111.908 0c.058.467-.172.92-.57 1.174A9.953 9.953 0 017 18a9.953 9.953 0 01-5.385-1.572zM14.5 16h-.106c.07-.297.088-.611.048-.933a7.47 7.47 0 00-1.588-3.755 4.502 4.502 0 015.874 2.636.818.818 0 01-.36.98A7.465 7.465 0 0114.5 16z"></path>
    //                             </svg>
    //                             {state.get_industry_by_id(job.industry_id)}
    //                         </div>
    //                     </div>
    //                     <div class="ml-2 flex items-center text-sm text-gray-500">
    //                         <svg class="mr-1.5 h-4 w-4 flex-shrink-0 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
    //                             <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
    //                         </svg>
    //                         {realize_date(&job.created_at.clone())}
    //                     </div>
    //                 </div>
    //             </div>
    //         </Link<JobsRoute>>
    //     </li>
    // }).collect::<Vec<_>>();

    html! {
        // if jobs_len > 0 {
        //     <ul role="list" class="divide-y divide-gray-200">
        //         {for posts}
        //     </ul>
        // } else {
            <div class="p-10 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
                    <path vector-effect="non-scaling-stroke" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6m-3-3v6m-9 1V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z" />
                </svg>
                <h3 class="mt-2 text-sm font-semibold text-gray-900">{"No jobs found"}</h3>
                <p class="mt-1 text-sm text-gray-500">{"Get started by creating a new gig post."}</p>
                <div class="mt-6">
                    <a href="https://t.me/osslocal"
                        type="button"
                        class="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                        <svg class="-ml-0.5 mr-1.5 h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"
                            data-slot="icon">
                            <path
                                d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
                        </svg>
                        {"New Gig Post"}
                    </a>
                </div>
            </div>
        // }
    }
}