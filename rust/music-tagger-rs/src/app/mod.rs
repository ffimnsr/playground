use clap::Parser;
use std::error::Error;
use std::fs;
use std::io::{self, Write};
use std::path::Path;
use std::path::PathBuf;
use std::time::Duration;

use crate::domain::{parse_track_from_path, ReleaseCandidate, TrackTags};
use crate::infra::flac::write_flac_tags;
use crate::infra::musicbrainz::MusicBrainzClient;

#[derive(Debug, Parser)]
#[command(name = "music-tagger")]
#[command(about = "Tag FLAC files from filename metadata via MusicBrainz")]
struct Cli {
    #[arg(required = true)]
    files: Vec<PathBuf>,

    #[arg(
        long,
        default_value = "music-tagger/0.1.0 (music-tagger-qs.myv1e@8shield.net)"
    )]
    user_agent: String,

    #[arg(long, default_value_t = 1000)]
    min_interval_ms: u64,

    #[arg(long, default_value_t = false)]
    dry_run: bool,

    #[arg(long, default_value_t = false)]
    strict: bool,

    #[arg(long, default_value_t = false)]
    no_cover: bool,

    #[arg(long, default_value_t = false)]
    choose_release: bool,

    #[arg(long)]
    release_index: Option<usize>,

    #[arg(long)]
    release_id: Option<String>,

    #[arg(long, default_value_t = false)]
    print_release_candidates: bool,

    #[arg(long, default_value_t = false)]
    recursive: bool,
}

pub fn run() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();

    if matches!(cli.release_index, Some(0)) {
        return Err("--release-index must be >= 1".into());
    }

    let mut client = MusicBrainzClient::new(cli.user_agent, Duration::from_millis(cli.min_interval_ms))?;
    let mut failures = 0usize;
    let mut matched = 0usize;
    let mut tagged = 0usize;
    let files = collect_input_files(&cli.files, cli.recursive)?;

    for file in &files {
        let Some(parsed) = parse_track_from_path(file) else {
            eprintln!(
                "Skipping (could not parse filename pattern): {}",
                file.display()
            );
            failures += 1;
            continue;
        };

        let Some(recording_match) = client.search_recording(&parsed.artist, &parsed.title)? else {
            eprintln!(
                "No MusicBrainz match for: {} - {} ({})",
                parsed.artist,
                parsed.title,
                file.display()
            );
            failures += 1;
            continue;
        };

        if cli.print_release_candidates {
            println!(
                "Release candidates for {} - {} ({}):",
                recording_match.artist,
                recording_match.title,
                file.display()
            );
            print_release_candidates(&recording_match.releases);
            matched += 1;
            continue;
        }

        let selected_release = if let Some(release_id) = &cli.release_id {
            match choose_release_by_id(file, &recording_match.releases, release_id) {
                Some(release) => Some(release),
                None => {
                    failures += 1;
                    continue;
                }
            }
        } else if let Some(release_index) = cli.release_index {
            match choose_release_by_index(file, &recording_match.releases, release_index) {
                Some(release) => Some(release),
                None => {
                    failures += 1;
                    continue;
                }
            }
        } else if cli.choose_release {
            match choose_release_for_file(file, &recording_match.releases)? {
                Some(release) => Some(release),
                None => {
                    eprintln!("Skipping (no release selected): {}", file.display());
                    failures += 1;
                    continue;
                }
            }
        } else {
            choose_default_release(file, &recording_match.releases, &parsed.title)
        };

        let tags = recording_match.to_track_tags(selected_release.as_ref());

        matched += 1;
        report_match(file, &tags);

        let cover_jpeg = if cli.no_cover {
            println!("Cover: skipped (--no-cover)");
            None
        } else if let Some(release_id) = &tags.musicbrainz_release_id {
            let cover_url = MusicBrainzClient::cover_art_front_url(release_id);
            match client.fetch_cover_art_jpeg(release_id) {
                Ok(Some(bytes)) => {
                    println!(
                        "Cover: url='{}' (jpeg prepared: {} bytes)",
                        cover_url,
                        bytes.len()
                    );
                    Some(bytes)
                }
                Ok(None) => {
                    println!("Cover: not found at url='{}'", cover_url);
                    None
                }
                Err(error) => {
                    eprintln!("Cover fetch failed for {}: {error}", file.display());
                    println!("Cover: url='{}' (fetch failed)", cover_url);
                    None
                }
            }
        } else {
            println!("Cover: none (no release id from MusicBrainz match)");
            None
        };

        if cli.dry_run {
            continue;
        }

        if let Err(error) = write_flac_tags(
            file,
            &tags,
            parsed.youtube_id.as_deref(),
            cover_jpeg.as_deref(),
        ) {
            eprintln!("Failed to tag {}: {error}", file.display());
            failures += 1;
            continue;
        }

        tagged += 1;
        println!("Tagged: {}", file.display());
    }

    if cli.dry_run || cli.print_release_candidates {
        println!(
            "Summary: matched={}, failed={}, total={} (dry-run)",
            matched,
            failures,
            files.len()
        );
    } else {
        println!(
            "Summary: tagged={}, failed={}, total={}",
            tagged,
            failures,
            files.len()
        );
    }

    if cli.strict && failures > 0 {
        return Err(format!(
            "Strict mode failed: {failures} file(s) were skipped or could not be tagged"
        )
        .into());
    }

    Ok(())
}

fn choose_release_by_index(
    path: &PathBuf,
    releases: &[ReleaseCandidate],
    release_index: usize,
) -> Option<ReleaseCandidate> {
    let index = release_index.saturating_sub(1);
    let Some(selected) = releases.get(index).cloned() else {
        eprintln!(
            "Skipping (release index {} out of range 1-{}): {}",
            release_index,
            releases.len(),
            path.display()
        );
        return None;
    };

    let date = selected
        .date
        .clone()
        .unwrap_or_else(|| "unknown-date".to_string());
    println!(
        "Release selected by index {}: {} ({}) [{}]",
        release_index,
        selected.title,
        date,
        selected.id
    );

    Some(selected)
}

fn choose_release_by_id(
    path: &PathBuf,
    releases: &[ReleaseCandidate],
    release_id: &str,
) -> Option<ReleaseCandidate> {
    let Some(selected) = releases.iter().find(|release| release.id == release_id).cloned() else {
        eprintln!(
            "Skipping (release id '{}' not in candidates): {}",
            release_id,
            path.display()
        );
        return None;
    };

    let date = selected
        .date
        .clone()
        .unwrap_or_else(|| "unknown-date".to_string());
    println!(
        "Release selected by id {}: {} ({}) [{}]",
        release_id,
        selected.title,
        date,
        selected.id
    );

    Some(selected)
}

fn is_flac(path: &Path) -> bool {
    path.extension()
        .and_then(|ext| ext.to_str())
        .map(|ext| ext.eq_ignore_ascii_case("flac"))
        .unwrap_or(false)
}

fn choose_default_release(
    path: &PathBuf,
    releases: &[ReleaseCandidate],
    song_title: &str,
) -> Option<ReleaseCandidate> {
    if let Some(selected) = releases
        .iter()
        .find(|release| normalized_title_eq(&release.title, song_title))
        .cloned()
    {
        let date = selected
            .date
            .clone()
            .unwrap_or_else(|| "unknown-date".to_string());
        println!(
            "Release selected by title match: {} ({}) [{}]",
            selected.title, date, selected.id
        );
        return Some(selected);
    }

    let selected = releases.first().cloned();
    if let Some(first) = &selected {
        let date = first
            .date
            .clone()
            .unwrap_or_else(|| "unknown-date".to_string());
        println!(
            "Release selected by fallback (first candidate): {} ({}) [{}] ({})",
            first.title,
            date,
            first.id,
            path.display()
        );
    }
    selected
}

fn normalized_title_eq(left: &str, right: &str) -> bool {
    normalize_title_for_match(left) == normalize_title_for_match(right)
}

fn normalize_title_for_match(value: &str) -> String {
    value.split_whitespace().collect::<Vec<_>>().join(" ").to_lowercase()
}

fn collect_input_files(inputs: &[PathBuf], recursive: bool) -> Result<Vec<PathBuf>, Box<dyn Error>> {
    let mut files = Vec::new();
    for input in inputs {
        collect_flac_paths(input, recursive, &mut files)?;
    }

    files.sort();
    files.dedup();

    if files.is_empty() {
        return Err("No FLAC files found in provided input paths".into());
    }

    Ok(files)
}

fn collect_flac_paths(path: &Path, recursive: bool, out: &mut Vec<PathBuf>) -> Result<(), Box<dyn Error>> {
    if path.is_file() {
        if is_flac(path) {
            out.push(path.to_path_buf());
        }
        return Ok(());
    }

    if path.is_dir() {
        let mut entries = fs::read_dir(path)?.collect::<Result<Vec<_>, _>>()?;
        entries.sort_by_key(|entry| entry.path());

        for entry in entries {
            let entry_path = entry.path();
            if entry_path.is_file() {
                if is_flac(&entry_path) {
                    out.push(entry_path);
                }
                continue;
            }

            if recursive && entry_path.is_dir() {
                collect_flac_paths(&entry_path, true, out)?;
            }
        }
        return Ok(());
    }

    Err(format!("Input path does not exist: {}", path.display()).into())
}

fn report_match(path: &PathBuf, tags: &TrackTags) {
    println!(
        "Match: {} => artist='{}', title='{}', album='{}'",
        path.display(),
        tags.artist,
        tags.title,
        tags.album.clone().unwrap_or_else(|| "".to_string())
    );
}

fn choose_release_for_file(
    path: &PathBuf,
    releases: &[ReleaseCandidate],
) -> Result<Option<ReleaseCandidate>, Box<dyn Error>> {
    if releases.is_empty() {
        println!("Release choices: none available for {}", path.display());
        return Ok(None);
    }

    println!("Release choices for {}:", path.display());
    for (index, release) in releases.iter().enumerate() {
        let date = release.date.clone().unwrap_or_else(|| "unknown-date".to_string());
        println!(
            "  [{}] {} ({}) [{}]",
            index + 1,
            release.title,
            date,
            release.id
        );
    }
    println!("  [0] skip file");

    loop {
        print!("Choose release [default 1]: ");
        io::stdout().flush()?;

        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        let trimmed = input.trim();

        if trimmed.is_empty() {
            return Ok(releases.first().cloned());
        }

        match trimmed.parse::<usize>() {
            Ok(0) => return Ok(None),
            Ok(value) if value >= 1 && value <= releases.len() => {
                return Ok(releases.get(value - 1).cloned())
            }
            _ => println!("Invalid choice. Enter 0-{}.", releases.len()),
        }
    }
}

fn print_release_candidates(releases: &[ReleaseCandidate]) {
    if releases.is_empty() {
        println!("  (none)");
        return;
    }

    for (index, release) in releases.iter().enumerate() {
        let date = release
            .date
            .clone()
            .unwrap_or_else(|| "unknown-date".to_string());
        println!("  [{}] {} ({}) [{}]", index + 1, release.title, date, release.id);
    }
}
