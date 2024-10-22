use chrono::DateTime;

pub mod footer;
pub mod gig;
pub mod header;
pub mod job;
pub mod modal;

pub use footer::Footer;
pub use header::Header;
pub use job::{JobsView, JobsViewLoading, JobDetailView, JobDetailViewLoading};
pub use gig::{GigsView, GigsViewLoading};
pub use modal::Modal;

fn title_case(input: &str) -> String {
    input
        .split_whitespace()
        .map(|word| {
            let mut chars = word.chars();
            match chars.next() {
                None => String::new(),
                Some(f) => f.to_uppercase().collect::<String>() + chars.as_str(),
            }
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn split_on_capitals(input: &str) -> Vec<String> {
    let mut result = Vec::new();
    let mut current = String::new();

    for c in input.chars() {
        if c.is_uppercase() && !current.is_empty() {
            result.push(current.clone());
            current.clear();
        }
        current.push(c);
    }

    if !current.is_empty() {
        result.push(current);
    }

    result
}

fn realize_contract_type(contract_type: Option<String>) -> String {
    if let Some(c) = contract_type {
        let c = split_on_capitals(&c);
        return c.join(" ");
    }

    "Not Specified".to_string()
}

fn realize_date(date: &str) -> String {
    let now = chrono::Utc::now();
    let dt = DateTime::parse_from_rfc3339(date).unwrap();
    if now.eq(&dt) {
        return "Today".to_string();
    }

    if now.signed_duration_since(dt).num_days() == 1 {
        return "Yesterday".to_string();
    }

    dt.format("%Y-%m-%d").to_string()
}