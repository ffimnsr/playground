use crate::model::*;
use bounce::*;

#[derive(Default, Debug, Clone, PartialEq, Atom)]
pub struct State {
    pub work_functions: WorkFunctions,
    pub work_industries: WorkIndustries,
}

#[allow(dead_code)]
impl State {
    pub fn get_industry_by_id(&self, id: i32) -> String {
        self.work_industries
            .iter()
            .find(|industry| industry.id == id)
            .map(|industry| industry.name.clone())
            .unwrap_or("Unknown".to_string())
    }

    pub fn get_function_by_id(&self, id: i32) -> String {
        self.work_functions
            .iter()
            .find(|function| function.id == id)
            .map(|function| function.name.clone())
            .unwrap_or("Unknown".to_string())
    }
}