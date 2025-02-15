use std::io::Write as _;
use std::{
    env,
    fs::{File, OpenOptions},
    path::Path,
    sync::Arc,
};

use chrono::{Local, Timelike};
use git2::{BranchType, Cred, IndexAddOption, PushOptions, RemoteCallbacks, Repository, Signature};
use rand::{Rng, rng, seq::IndexedRandom as _};
use tokio_cron_scheduler::{Job, JobScheduler};

/// Validate the SSH URL
/// # Arguments
/// * `url` - SSH URL
/// # Returns
/// * `Result` - Result of the operation
fn validate_ssh_url(url: &str) -> anyhow::Result<()> {
    if !url.starts_with("git@") || !url.contains(":") {
        anyhow::bail!("Invalid SSH URL format. Expected: git@hostname:username/repository.git");
    }
    Ok(())
}

/// Create a signature
/// # Returns
/// * `Result` - Result of the operation
fn create_signature() -> anyhow::Result<Signature<'static>> {
    // Create signature from scratch
    let name = env::var("DC_COMMITTER_NAME").unwrap_or_else(|_| "Daily Committer".to_string());
    let email =
        env::var("DC_COMMITTER_EMAIL").unwrap_or_else(|_| "daily-committer@bot.com".to_string());
    let signature = Signature::now(&name, &email)?;

    Ok(signature)
}

/// Update the README file
/// # Arguments
/// * `repo_path` - Path to the repository
/// # Returns
/// * `Result` - Result of the operation
fn update_readme(repo_path: &str) -> anyhow::Result<()> {
    // Touch a README file
    let readme = Path::new(repo_path).join("README.md");
    if !readme.exists() {
        File::create(&readme)?;
    }

    // Open the README file
    let mut file = OpenOptions::new()
        .write(true)
        .truncate(true)
        .create(true)
        .open(&readme)?;

    // Write the current date to the file
    let current_time = Local::now();
    writeln!(
        file,
        "Last updated: {}",
        current_time.format("%Y-%m-%d %H:%M:%S")
    )?;

    Ok(())
}

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

    // Check and switch to main branch
    // If main branch doesn't exist, create it
    // If refs doesn't exist, create initial commit
    let head = match repo.head() {
        Ok(head) => head,
        Err(_) => {
            // Create initial commit if repository is empty
            println!("Creating initial commit on main branch...");

            // Create an empty tree
            let tree_id = repo.index()?.write_tree()?;
            let tree = repo.find_tree(tree_id)?;

            // Create signature
            let signature = match repo.signature() {
                Ok(signature) => signature,
                Err(_) => create_signature()?,
            };

            // Create initial commit
            repo.commit(
                Some("refs/heads/main"),
                &signature,
                &signature,
                "🎉 Initial commit",
                &tree,
                &[],
            )?;

            // Set HEAD to main branch
            repo.set_head("refs/heads/main")?;

            // Get the head reference
            repo.head()?
        }
    };

    println!("Current branch: {:?}", head.name());

    // Check if the main branch exists
    if head.name() != Some("refs/heads/main") {
        // Try to find main branch
        if let Ok(mut branch) = repo.find_branch("main", BranchType::Local) {
            branch.set_upstream(Some("origin/main"))?;
            repo.set_head(branch.get().name().unwrap())?;
        } else {
            // Create main branch if it doesn't exist
            let head_commit = head.peel_to_commit()?;
            repo.branch("main", &head_commit, false)?;
            repo.set_head("refs/heads/main")?;
        }
    }

    // Update the README file
    update_readme(repo_path)?;

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
    let signature = match repo.signature() {
        Ok(signature) => signature,
        Err(_) => create_signature()?,
    };

    // Get HEAD and parent commit
    let parent_commit = repo.head()?.peel_to_commit().ok();

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
    let mut remote = match repo.find_remote("origin") {
        Ok(remote) => remote,
        Err(_) => {
            let remote_url = env::var("DC_REMOTE_URL").ok();
            if let Some(url) = remote_url {
                // Validate if the URL is in SSH format
                validate_ssh_url(&url)?;

                // Add the remote
                println!("Remote 'origin' not found, creating it...");
                repo.remote("origin", &url)?
            } else {
                anyhow::bail!("Remote 'origin' not found and no URL provided");
            }
        }
    };

    // Set up SSH authentication

    let mut callbacks = RemoteCallbacks::new();
    callbacks.credentials(|_url, username_from_url, _allowed_types| {
        let username = username_from_url.unwrap_or("git");
        let home = env::var("HOME").unwrap_or_else(|_| "/root".to_string());

        let ssh_ed25519_key_path = format!("{}/.ssh/id_ed25519", home);
        let ssh_ed25519_key = Path::new(&ssh_ed25519_key_path);
        let ssh_rsa_key_path = format!("{}/.ssh/id_rsa", home);
        let ssh_rsa_key = Path::new(&ssh_rsa_key_path);

        if ssh_ed25519_key.exists() {
            Cred::ssh_key(username, None, ssh_ed25519_key, None)
        } else if ssh_rsa_key.exists() {
            Cred::ssh_key(username, None, ssh_rsa_key, None)
        } else {
            Cred::ssh_key_from_agent(username)
        }
    });

    // Set up push options
    let mut push_options = PushOptions::new();
    push_options.remote_callbacks(callbacks);

    // Push the changes to remote using the main branch
    let refspec = "refs/heads/main:refs/heads/main";
    remote.push(&[refspec], Some(&mut push_options))?;

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
    hours: &[u32],
) -> anyhow::Result<()> {
    // Schedule a new job for each chosen hour
    for hour in hours.iter().copied() {
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
    hour: u32,
) -> anyhow::Result<()> {
    // Clone the repository path as it will be moved into the job
    let repo_path = repo_path.to_string();

    // Add a new job to the scheduler
    scheduler
        .add(Job::new_async(cron_expr, move |_, _| {
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
fn generate_chosen_hours() -> Vec<u32> {
    // Get the current hour
    let current_hour = Local::now().hour();

    // Ensure the current hour is not 0 or greater than 24
    // Handle the edge case by setting it to 1
    let current_hour = if current_hour == 0 || current_hour > 24 {
        1
    } else {
        current_hour
    };

    // Generate a list of hours from 1 to 24
    let hours: Vec<_> = (current_hour..=24).collect();

    // Choose a random number of hours
    let mut rng = rng();

    // Generate a random number of commits
    let num_commits = rng.random_range(1..=8);

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

    commit_changes(&repo_path, false)?;

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

    // Shutdown the scheduler when Ctrl+C is pressed
    scheduler.shutdown_on_ctrl_c();

    // Start the scheduler
    scheduler.start().await?;

    // Keep the program running
    tokio::signal::ctrl_c().await?;

    Ok(())
}
