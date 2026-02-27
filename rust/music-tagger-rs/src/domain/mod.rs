use std::path::Path;

#[derive(Debug, Clone)]
pub struct ParsedTrack {
    pub artist: String,
    pub title: String,
    pub youtube_id: Option<String>,
}

#[derive(Debug, Clone)]
pub struct TrackTags {
    pub artist: String,
    pub title: String,
    pub album: Option<String>,
    pub date: Option<String>,
    pub musicbrainz_recording_id: String,
    pub musicbrainz_release_id: Option<String>,
}

#[derive(Debug, Clone)]
pub struct ReleaseCandidate {
    pub recording_id: String,
    pub id: String,
    pub title: String,
    pub date: Option<String>,
}

#[derive(Debug, Clone)]
pub struct RecordingMatch {
    pub artist: String,
    pub title: String,
    pub musicbrainz_recording_id: String,
    pub releases: Vec<ReleaseCandidate>,
}

impl RecordingMatch {
    pub fn to_track_tags(&self, release: Option<&ReleaseCandidate>) -> TrackTags {
        TrackTags {
            artist: self.artist.clone(),
            title: self.title.clone(),
            album: release.map(|item| item.title.clone()),
            date: release.and_then(|item| item.date.clone()),
            musicbrainz_recording_id: release
                .map(|item| item.recording_id.clone())
                .unwrap_or_else(|| self.musicbrainz_recording_id.clone()),
            musicbrainz_release_id: release.map(|item| item.id.clone()),
        }
    }
}

pub fn parse_track_from_path(path: &Path) -> Option<ParsedTrack> {
    let stem = path.file_stem()?.to_str()?.trim();
    let (artist_part, title_part) = stem.split_once(" - ")?;

    let artist = artist_part.trim();
    if artist.is_empty() {
        return None;
    }

    let (title, youtube_id) = parse_title_and_youtube_id(title_part.trim());
    if title.is_empty() {
        return None;
    }

    Some(ParsedTrack {
        artist: artist.to_string(),
        title,
        youtube_id,
    })
}

fn parse_title_and_youtube_id(raw: &str) -> (String, Option<String>) {
    if let Some((title_part, trailing)) = raw.rsplit_once(" [") {
        if let Some(id) = trailing.strip_suffix(']') {
            let id_trimmed = id.trim();
            if !id_trimmed.is_empty() {
                return (title_part.trim().to_string(), Some(id_trimmed.to_string()));
            }
        }
    }

    (raw.trim().to_string(), None)
}
