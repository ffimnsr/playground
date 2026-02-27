use clap::Parser;
use std::error::Error;
use std::io::{self, Write};
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

    for file in &cli.files {
        if !is_flac(file) {
            eprintln!("Skipping non-FLAC: {}", file.display());
            failures += 1;
            continue;
        }

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
            recording_match.releases.first().cloned()
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
            cli.files.len()
        );
    } else {
        println!(
            "Summary: tagged={}, failed={}, total={}",
            tagged,
            failures,
            cli.files.len()
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

fn is_flac(path: &PathBuf) -> bool {
    path.extension()
        .and_then(|ext| ext.to_str())
        .map(|ext| ext.eq_ignore_ascii_case("flac"))
        .unwrap_or(false)
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
