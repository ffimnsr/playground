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
        self.wait_for_rate_limit();

        let query = format!(
            "artist:\"{}\" AND recording:\"{}\"",
            escape_query_value(artist),
            escape_query_value(title)
        );

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
        let Some(primary_recording) = body.recordings.first() else {
            return Ok(None);
        };

        let artist_name = artist_from_credit(&primary_recording.artist_credit)
            .unwrap_or_else(|| artist.to_string());

        let mut releases = Vec::new();
        let mut seen_release_ids = HashSet::new();

        for recording in &body.recordings {
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

        releases.sort_by(|left, right| {
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
            releases,
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

fn escape_query_value(value: &str) -> String {
    value.replace('"', "")
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
