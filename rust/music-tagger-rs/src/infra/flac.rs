use std::error::Error;
use std::path::Path;

use metaflac::block::PictureType;

use crate::domain::TrackTags;

pub fn write_flac_tags(
    path: &Path,
    tags: &TrackTags,
    youtube_id: Option<&str>,
    cover_jpeg: Option<&[u8]>,
) -> Result<(), Box<dyn Error>> {
    let mut tag = metaflac::Tag::read_from_path(path)?;

    tag.set_vorbis("TITLE", vec![tags.title.as_str()]);
    tag.set_vorbis("ARTIST", vec![tags.artist.as_str()]);
    tag.set_vorbis("ALBUMARTIST", vec![tags.artist.as_str()]);

    if let Some(album) = &tags.album {
        tag.set_vorbis("ALBUM", vec![album.as_str()]);
    }

    if let Some(date) = &tags.date {
        tag.set_vorbis("DATE", vec![date.as_str()]);
    }

    tag.set_vorbis(
        "MUSICBRAINZ_RECORDINGID",
        vec![tags.musicbrainz_recording_id.as_str()],
    );

    if let Some(id) = youtube_id {
        tag.set_vorbis("YOUTUBE_ID", vec![id]);
    }

    if let Some(jpeg_bytes) = cover_jpeg {
        tag.remove_picture_type(PictureType::CoverFront);
        tag.add_picture("image/jpeg", PictureType::CoverFront, jpeg_bytes.to_vec());
    }

    tag.write_to_path(path)?;
    Ok(())
}
