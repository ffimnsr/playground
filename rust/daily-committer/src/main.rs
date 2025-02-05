use std::{env, sync::Arc, time::Duration};

use git2::{IndexAddOption, Repository, Signature};
use rand::{Rng, rng, seq::IndexedRandom as _};
use tokio_cron_scheduler::{Job, JobScheduler};

/// Commit changes in the repository
/// # Arguments
/// * `repo_path` - Path to the repository
/// * `dry_run` - If true, don't commit changes
/// # Returns
/// * `Result` - Result of the operation
fn commit_changes(repo_path: &str, dry_run: bool) -> anyhow::Result<()> {
    // Check if dry run
    // If dry run, print the message and return
    if dry_run {
        println!("Dry run - commit changes in {}", repo_path);
        return Ok(());
    }

    // Open the repository
    let repo = match Repository::open(repo_path) {
        Ok(repo) => repo,
        Err(e) => panic!("Failed to open: {}", e),
    };

    // Check if the repository is bare
    if repo.is_bare() {
        anyhow::bail!("Can't work on bare repository");
    }

    // Get the repository index
    let mut index = repo.index()?;

    // Add all files to the index
    index.add_all(["*"].iter(), IndexAddOption::DEFAULT, None)?;

    // Write the index
    index.write()?;

    // Create the commit
    let tree_id = index.write_tree()?;
    let tree = repo.find_tree(tree_id)?;

    // Create signature from scratch
    let signature = Signature::now(
        "Daily Committer",
        "daily-committer@bot.com",
    )?;

    // Get HEAD and parent commit
    let parent_commit = match repo.head()?.peel_to_commit() {
        Ok(commit) => Some(commit),
        Err(_) => None,
    };

    // Create a list of parent commits
    let parents = parent_commit.as_ref().map(|c| vec![c]).unwrap_or(vec![]);

    // Create the commit
    repo.commit(
        Some("HEAD"),
        &signature,
        &signature,
        "🍕 Add daily commit",
        &tree,
        parents.as_slice(),
    )?;

    // Find the default remote (usually "origin")
    let mut remote = repo.find_remote("origin")?;

    // Push the changes to remote using the main branch
    let refspec = "refs/heads/main:refs/heads/main";
    remote.push(&[refspec], None)?;

    println!("Changes pushed to remote repository");

    Ok(())
}

/// Check if the repository exists
/// # Arguments
/// * `repo_path` - Path to the repository
/// # Returns
/// * `bool` - True if the repository exists, false otherwise
fn check_repo(repo_path: &str) -> bool {
    // Open the repository
    let repo = match Repository::open(repo_path) {
        Ok(repo) => repo,
        Err(_) => return false,
    };

    // Check if the repository is bare
    if repo.is_bare() {
        return false;
    }

    true
}

/// Schedule a random job
/// # Arguments
/// * `scheduler` - Job scheduler
/// * `repo_path` - Path to the repository
/// # Returns
/// * `Result` - Result of the operation
async fn schedule_random_job(
    scheduler: &JobScheduler,
    repo_path: &str,
    hours: &[i32],
) -> anyhow::Result<()> {
    // Schedule a new job for each chosen hour
    for hour in hours.to_owned() {
        // Generate the cron expression
        let cron_expr: &str = &format!("0 0 {} * * *", hour);
        println!("Added new job scheduled for {:02}:00", hour);

        // Schedule the job
        schedule_job(scheduler, repo_path, cron_expr, hour).await?;
    }

    Ok(())
}

/// Schedule an initial job
/// # Arguments
/// * `scheduler` - Job scheduler
/// * `repo_path` - Path to the repository
/// # Returns
/// * `Result` - Result of the operation
async fn schedule_initial_job(scheduler: &JobScheduler, repo_path: &str) -> anyhow::Result<()> {
    // Generate a list of chosen hours
    let hours = generate_chosen_hours();

    // Get the first hour from the list
    let hour = *hours.first().unwrap_or(&11);

    // Generate the cron expression
    let cron_expr: &str = &format!("0 0 {} * * *", hour);
    println!("Added new job scheduled for {:02}:00", hour);

    // Schedule the job
    schedule_job(scheduler, repo_path, cron_expr, hour).await?;

    Ok(())
}

/// Schedule a job
/// # Arguments
/// * `scheduler` - Job scheduler
/// * `repo_path` - Path to the repository
/// * `cron_expr` - Cron expression
/// * `hour` - Hour of the day
/// # Returns
/// * `Result` - Result of the operation
async fn schedule_job(
    scheduler: &JobScheduler,
    repo_path: &str,
    cron_expr: &str,
    hour: i32,
) -> anyhow::Result<()> {
    // Clone the repository path as it will be moved into the job
    let repo_path = repo_path.to_string();

    // Add a new job to the scheduler
    scheduler
        .add(Job::new_async(&cron_expr, move |_, _| {
            let repo_path = repo_path.clone();
            Box::pin(async move {
                if let Err(e) = commit_changes(&repo_path, false) {
                    eprintln!("Failed to commit changes at {:02}:00: {}", hour, e);
                } else {
                    println!("Successfully committed changes at {:02}:00", hour);
                }
            })
        })?)
        .await?;

    Ok(())
}

/// Generate a list of chosen hours
fn generate_chosen_hours() -> Vec<i32> {
    // Generate a list of hours from 1 to 24
    let hours: Vec<_> = (1..=24).collect();

    // Choose a random number of hours
    let mut rng = rng();
    let num_commits = rng.random_range(1..=4);

    // Choose random hours from the list
    let mut chosen_hours: Vec<_> = hours
        .choose_multiple(&mut rng, num_commits)
        .cloned()
        .collect();

    // Sort the chosen hours
    chosen_hours.sort();
    chosen_hours
}

/// Main function
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Get the repository path from the command line arguments
    let args: Vec<String> = env::args().collect();
    let repo_path = match args.get(1) {
        Some(path) => path.clone(),
        None => {
            eprintln!("Usage: {} <repository_path>", args[0]);
            anyhow::bail!("Please provide a path to the repository");
        }
    };

    // Check if the repository exists
    if !check_repo(&repo_path) {
        anyhow::bail!("Invalid repository path: {}", repo_path);
    }

    // Create a new scheduler
    let scheduler = JobScheduler::new().await?;
    let scheduler = Arc::new(scheduler);
    let scheduler_clone = scheduler.clone();

    // Schedule initial random job
    schedule_initial_job(&scheduler, &repo_path).await?;

    // Add a job to schedule new random jobs every day
    scheduler
        .add(Job::new_async("0 0 0 * * *", move |_, _| {
            let repo_path = repo_path.clone();
            let scheduler_clone = scheduler_clone.clone();
            Box::pin(async move {
                let hours = generate_chosen_hours();
                if let Err(e) = schedule_random_job(&scheduler_clone, &repo_path, &hours).await {
                    eprintln!("Failed to schedule new random job: {}", e);
                }
            })
        })?)
        .await?;

    // Run a job once after 18 seconds
    scheduler
        .add(Job::new_one_shot(Duration::from_secs(5), |_uuid, _l| {
            println!("I only run once");
        })?)
        .await?;

    // Shutdown the scheduler when Ctrl+C is pressed
    scheduler.shutdown_on_ctrl_c();

    // Start the scheduler
    scheduler.start().await?;

    // Keep the program running
    tokio::signal::ctrl_c().await?;

    Ok(())
}
