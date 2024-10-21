pub mod job;
pub mod work_function;
pub mod work_industry;

pub use job::Job;
pub use work_function::WorkFunction;
pub use work_industry::WorkIndustry;

pub type Jobs = Vec<Job>;
pub type WorkFunctions = Vec<WorkFunction>;
pub type WorkIndustries = Vec<WorkIndustry>;
