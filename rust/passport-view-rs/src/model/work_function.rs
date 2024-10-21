use serde::Deserialize;

#[derive(Default, Debug, Clone, PartialEq, Deserialize)]
pub struct WorkFunction {
    pub id: i32,
    pub name: String,
    pub status: i16,
    pub created_at: String,
    pub updated_at: String,
}