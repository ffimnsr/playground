use yew::prelude::*;
use serde::Deserialize;

#[derive(Clone, PartialEq, Deserialize)]
pub struct Job {
    pub id: i32,
    pub title: String,
    pub description: String,
    pub experience_level: Option<String>,
    pub salary_upper_limit: Option<String>,
    pub salary_lower_limit: Option<String>,
    pub salary_currency: Option<String>,
    pub salary_timeframe: Option<String>,
    pub work_type: Option<String>,
    pub has_timetracker: Option<bool>,
    pub status: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}

#[derive(PartialEq, Properties)]
pub struct JobsListProps {
    pub jobs: Vec<Job>,
}

#[function_component(JobsList)]
pub fn jobs_list(JobsListProps { jobs }: &JobsListProps) -> Html {
    jobs.iter().map(|job| html! {
        <p key={job.id}>{format!("{}: {}", job.title, job.description)}</p>
    }).collect()
}
