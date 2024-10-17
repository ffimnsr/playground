use serde::Deserialize;

#[derive(Clone, PartialEq, Deserialize)]
pub struct SalaryDetail {
    upper_limit: Option<String>,
    lower_limit: Option<String>,
    currency: Option<String>,
    timeframe: Option<String>,
}


#[derive(Clone, PartialEq, Deserialize)]
pub struct Job {
    pub id: String,
    pub title: String,
    pub description: String,
    pub industry_id: i32,
    pub country_id: i32,
    pub organization_id: i64,
    pub work_experience_level: Option<String>,
    pub work_contract_type: Option<String>,
    pub salary: Option<SalaryDetail>,
    pub has_timetracker: bool,
    pub is_remote: bool,
    pub is_featured: bool,
    pub status: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}
