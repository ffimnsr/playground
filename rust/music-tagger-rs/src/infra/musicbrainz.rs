use std::error::Error;
use std::collections::HashSet;
use std::thread;
use std::time::{Duration, Instant};

use image::codecs::jpeg::JpegEncoder;
use image::ImageReader;
use reqwest::blocking::Client;
use serde::Deserialize;

use crate::domain::{RecordingMatch, ReleaseCandidate};

const API_ROOT: &str = "https://musicbrainz.org/ws/2";
const COVER_ART_ROOT: &str = "https://coverartarchive.org";

pub struct MusicBrainzClient {
    client: Client,
    min_interval: Duration,
    last_request_at: Option<Instant>,
}

impl MusicBrainzClient {
    pub fn new(user_agent: String, min_interval: Duration) -> Result<Self, Box<dyn Error>> {
        let client = Client::builder().user_agent(user_agent).build()?;

        Ok(Self {
            client,
            min_interval,
            last_request_at: None,
        })
    }

    pub fn search_recording(
        &mut self,
        artist: &str,
        title: &str,
    ) -> Result<Option<RecordingMatch>, Box<dyn Error>> {
        let mut recordings = Vec::new();
        for query in build_query_variants(artist, title) {
            self.wait_for_rate_limit();

            let response = self
                .client
                .get(format!("{API_ROOT}/recording"))
                .query(&[
                    ("query", query.as_str()),
                    ("fmt", "json"),
                    ("limit", "10"),
                    ("inc", "releases+artist-credits"),
                ])
                .send()?
                .error_for_status()?;

            self.last_request_at = Some(Instant::now());

            let body: RecordingSearchResponse = response.json()?;
            if !body.recordings.is_empty() {
                recordings = body.recordings;
                break;
            }
        }

        let Some(primary_recording) = recordings.first() else {
            return Ok(None);
        };

        let artist_name = artist_from_credit(&primary_recording.artist_credit)
            .unwrap_or_else(|| artist.to_string());

        let mut releases = Vec::new();
        let mut seen_release_ids = HashSet::new();

        for recording in &recordings {
            let mut from_browse = self.fetch_recording_releases(&recording.id)?;
            if from_browse.is_empty() {
                from_browse = recording
                    .releases
                    .iter()
                    .map(|release| ReleaseCandidate {
                        recording_id: recording.id.clone(),
                        id: release.id.clone(),
                        title: release.title.clone(),
                        date: release.date.clone(),
                    })
                    .collect();
            }

            for release in from_browse {
                if seen_release_ids.insert(release.id.clone()) {
                    releases.push(release);
                }
            }
        }

        let mut filtered_releases: Vec<ReleaseCandidate> = releases
            .iter()
            .filter(|release| !is_ignored_compilation_release_title(&release.title))
            .cloned()
            .collect();

        if filtered_releases.is_empty() {
            filtered_releases = releases;
        }

        filtered_releases.sort_by(|left, right| {
            let left_date = left.date.as_deref().unwrap_or("9999-99-99");
            let right_date = right.date.as_deref().unwrap_or("9999-99-99");
            left_date
                .cmp(right_date)
                .then_with(|| left.title.to_lowercase().cmp(&right.title.to_lowercase()))
        });

        Ok(Some(RecordingMatch {
            artist: artist_name,
            title: primary_recording.title.clone(),
            musicbrainz_recording_id: primary_recording.id.clone(),
            releases: filtered_releases,
        }))
    }

    pub fn cover_art_front_url(release_id: &str) -> String {
        format!("{COVER_ART_ROOT}/release/{release_id}/front")
    }

    pub fn fetch_cover_art_jpeg(
        &mut self,
        release_id: &str,
    ) -> Result<Option<Vec<u8>>, Box<dyn Error>> {
        self.wait_for_rate_limit();

        let response = self
            .client
            .get(Self::cover_art_front_url(release_id))
            .send()?;

        if response.status().as_u16() == 404 {
            self.last_request_at = Some(Instant::now());
            return Ok(None);
        }

        let response = response.error_for_status()?;
        let bytes = response.bytes()?;
        let jpeg = recode_to_jpeg(bytes.as_ref())?;
        self.last_request_at = Some(Instant::now());
        Ok(Some(jpeg))
    }

    fn fetch_recording_releases(
        &mut self,
        recording_id: &str,
    ) -> Result<Vec<ReleaseCandidate>, Box<dyn Error>> {
        let mut offset = 0usize;
        let mut all = Vec::new();
        let mut seen = HashSet::new();

        loop {
            self.wait_for_rate_limit();

            let response = self
                .client
                .get(format!("{API_ROOT}/release"))
                .query(&[
                    ("recording", recording_id),
                    ("fmt", "json"),
                    ("limit", "100"),
                    ("offset", &offset.to_string()),
                ])
                .send()?
                .error_for_status()?;

            self.last_request_at = Some(Instant::now());

            let body: ReleaseBrowseResponse = response.json()?;
            if body.releases.is_empty() {
                break;
            }

            let page_count = body.releases.len();
            for release in body.releases {
                if seen.insert(release.id.clone()) {
                    all.push(ReleaseCandidate {
                        recording_id: recording_id.to_string(),
                        id: release.id,
                        title: release.title,
                        date: release.date,
                    });
                }
            }

            offset += page_count;
            if offset >= body.release_count.unwrap_or(offset) {
                break;
            }
        }

        all.sort_by(|left, right| {
            let left_date = left.date.as_deref().unwrap_or("9999-99-99");
            let right_date = right.date.as_deref().unwrap_or("9999-99-99");
            left_date
                .cmp(right_date)
                .then_with(|| left.title.to_lowercase().cmp(&right.title.to_lowercase()))
        });

        Ok(all)
    }

    fn wait_for_rate_limit(&self) {
        if let Some(last_request_at) = self.last_request_at {
            let elapsed = last_request_at.elapsed();
            if elapsed < self.min_interval {
                thread::sleep(self.min_interval - elapsed);
            }
        }
    }
}

fn build_query_variants(artist: &str, title: &str) -> Vec<String> {
    let exact_artist = clean_spaces(artist);
    let exact_title = clean_spaces(title);
    let normalized_artist = normalize_artist(artist);
    let normalized_title = normalize_title(title);

    let mut variants = Vec::new();

    push_query(
        &mut variants,
        Some(exact_artist.as_str()),
        exact_title.as_str(),
    );
    push_query(
        &mut variants,
        Some(normalized_artist.as_str()),
        exact_title.as_str(),
    );
    push_query(
        &mut variants,
        Some(exact_artist.as_str()),
        normalized_title.as_str(),
    );
    push_query(
        &mut variants,
        Some(normalized_artist.as_str()),
        normalized_title.as_str(),
    );
    push_query(&mut variants, None, normalized_title.as_str());
    push_query(&mut variants, None, exact_title.as_str());

    let mut deduped = Vec::new();
    let mut seen = HashSet::new();
    for query in variants {
        if seen.insert(query.clone()) {
            deduped.push(query);
        }
    }

    deduped
}

fn push_query(queries: &mut Vec<String>, artist: Option<&str>, title: &str) {
    if title.trim().is_empty() {
        return;
    }

    let recording = escape_query_value(title);
    if let Some(artist_value) = artist {
        if !artist_value.trim().is_empty() {
            let artist_part = escape_query_value(artist_value);
            queries.push(format!(
                "artist:\"{}\" AND recording:\"{}\"",
                artist_part, recording
            ));
            return;
        }
    }

    queries.push(format!("recording:\"{}\"", recording));
}

fn normalize_artist(artist: &str) -> String {
    clean_spaces(&artist.replace('&', " and "))
}

fn normalize_title(title: &str) -> String {
    let mut value = clean_spaces(title);
    value = strip_feature_segment(&value);
    value = strip_noise_suffixes(&value);
    clean_spaces(&value)
}

fn strip_feature_segment(title: &str) -> String {
    let lower = title.to_lowercase();
    let markers = [" feat. ", " ft. ", " featuring ", " feat ", " ft "];

    let mut cut_index: Option<usize> = None;
    for marker in markers {
        if let Some(index) = lower.find(marker) {
            cut_index = Some(match cut_index {
                Some(existing) => existing.min(index),
                None => index,
            });
        }
    }

    if let Some(index) = cut_index {
        return title[..index].trim().to_string();
    }

    title.to_string()
}

fn strip_noise_suffixes(title: &str) -> String {
    let mut value = title.trim().to_string();

    for separator in [" ｜", " |", " - "] {
        if let Some(index) = value.find(separator) {
            let suffix = value[index + separator.len()..].to_lowercase();
            if contains_noise_word(&suffix) {
                value = value[..index].trim().to_string();
            }
        }
    }

    loop {
        let Some(end_index) = value.rfind(')') else {
            break;
        };
        if end_index != value.len() - 1 {
            break;
        }
        let Some(start_index) = value[..end_index].rfind('(') else {
            break;
        };

        let inside = value[start_index + 1..end_index].to_lowercase();
        if !contains_noise_word(&inside) {
            break;
        }

        value = value[..start_index].trim().to_string();
    }

    value
}

fn contains_noise_word(value: &str) -> bool {
    [
        "cover",
        "live",
        "lyrics",
        "tiny desk",
        "wish",
        "bus",
        "full",
        "prod.",
        "concert",
        "version",
    ]
    .iter()
    .any(|word| value.contains(word))
}

fn clean_spaces(value: &str) -> String {
    value.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn escape_query_value(value: &str) -> String {
    value.replace('"', "")
}

fn is_ignored_compilation_release_title(title: &str) -> bool {
    let lower = clean_spaces(title).to_lowercase();
    let normalized = normalize_compilation_title(&lower);

    if normalized.contains("top hits") {
        return true;
    }

    if normalized.contains("so fresh") && normalized.contains("hits") {
        return true;
    }

    if normalized.contains("hits")
        && (contains_year(&normalized)
            || contains_decade_token(&normalized)
            || normalized.contains("edition")
            || normalized.contains("summer")
            || normalized.contains("autumn")
            || normalized.contains("winter")
            || normalized.contains("spring"))
    {
        return true;
    }

    if normalized.contains("collection")
        && (normalized.contains("no 1") || normalized.contains("number 1"))
        && (contains_year(&normalized)
            || contains_decade_token(&normalized)
            || normalized.contains("digital collection"))
    {
        return true;
    }

    if normalized.contains("dj collection")
        && (contains_year(&normalized)
            || contains_decade_token(&normalized)
            || normalized.contains("digital collection"))
    {
        return true;
    }

    false
}

fn normalize_compilation_title(value: &str) -> String {
    value
        .chars()
        .map(|char| {
            if char.is_ascii_alphanumeric() || char.is_whitespace() {
                char
            } else {
                ' '
            }
        })
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
}

fn contains_year(value: &str) -> bool {
    value
        .split(|char: char| !char.is_ascii_digit())
        .filter(|part| part.len() == 4)
        .filter_map(|part| part.parse::<u16>().ok())
        .any(|year| (1900..=2099).contains(&year))
}

fn contains_decade_token(value: &str) -> bool {
    value
        .split_whitespace()
        .filter(|part| part.len() == 5 && part.ends_with('s'))
        .filter_map(|part| part[..4].parse::<u16>().ok())
        .any(|year| (1900..=2099).contains(&year))
}

fn artist_from_credit(credits: &[ArtistCredit]) -> Option<String> {
    if credits.is_empty() {
        return None;
    }

    let mut value = String::new();
    for credit in credits {
        value.push_str(&credit.name);
        if let Some(join_phrase) = &credit.join_phrase {
            value.push_str(join_phrase);
        }
    }

    if value.trim().is_empty() {
        None
    } else {
        Some(value)
    }
}

#[derive(Debug, Deserialize)]
struct RecordingSearchResponse {
    #[serde(default)]
    recordings: Vec<Recording>,
}

#[derive(Debug, Deserialize)]
struct Recording {
    id: String,
    title: String,
    #[serde(default, rename = "artist-credit")]
    artist_credit: Vec<ArtistCredit>,
    #[serde(default)]
    releases: Vec<Release>,
}

#[derive(Debug, Deserialize)]
struct ArtistCredit {
    name: String,
    #[serde(default, rename = "joinphrase")]
    join_phrase: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Release {
    id: String,
    title: String,
    #[serde(default)]
    date: Option<String>,
}

#[derive(Debug, Deserialize)]
struct ReleaseBrowseResponse {
    #[serde(default)]
    releases: Vec<Release>,
    #[serde(default, rename = "release-count")]
    release_count: Option<usize>,
}

fn recode_to_jpeg(image_bytes: &[u8]) -> Result<Vec<u8>, Box<dyn Error>> {
    let image = ImageReader::new(std::io::Cursor::new(image_bytes))
        .with_guessed_format()?
        .decode()?;

    let mut encoded = Vec::new();
    let mut encoder = JpegEncoder::new_with_quality(&mut encoded, 85);
    encoder.encode_image(&image)?;

    Ok(encoded)
}
