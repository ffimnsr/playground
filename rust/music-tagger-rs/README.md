# music-tagger

Simple FLAC tagger that:
- parses filenames like `musician - song name [youtube-id].flac`
- searches MusicBrainz for the best recording match
- writes Vorbis tags into the FLAC file

## Usage

Build:

```bash
cargo build
```

Dry run (no file changes):

```bash
cargo run -- --dry-run "Artist - Track [abc123].flac"
```

Tag files:

```bash
cargo run -- "Artist - Track [abc123].flac" "Another Artist - Song.flac"
```

Tag files without cover fetch/embed:

```bash
cargo run -- --no-cover "Artist - Track [abc123].flac"
```

Strict mode (exit non-zero if any file fails/skips):

```bash
cargo run -- --strict "Artist - Track [abc123].flac"
```

Interactively choose release/album from MusicBrainz candidates:

```bash
cargo run -- --choose-release "Artist - Track [abc123].flac"
```

Non-interactive release choice (useful for scripts):

```bash
cargo run -- --release-index 2 "Artist - Track [abc123].flac"
```

Deterministic release choice by MusicBrainz release ID:

```bash
cargo run -- --release-id 2f6e8ab7-5f84-4d1d-b105-c6ecf95a81f1 "Artist - Track [abc123].flac"
```

Print release candidates only (no tagging):

```bash
cargo run -- --print-release-candidates "Artist - Track [abc123].flac"
```

Set custom MusicBrainz user-agent:

```bash
cargo run -- --user-agent "music-tagger/0.1.0 (me@example.com)" "Artist - Track.flac"
```

All flags example:

```bash
cargo run -- \
	--dry-run \
	--strict \
	--no-cover \
	--choose-release \
	--release-index 1 \
	--release-id 2f6e8ab7-5f84-4d1d-b105-c6ecf95a81f1 \
	--print-release-candidates \
	--min-interval-ms 1000 \
	--user-agent "music-tagger/0.1.0 (me@example.com)" \
	"Artist - Track [abc123].flac"
```

## Notes

- MusicBrainz requires a meaningful user-agent.
- Default request pacing is 1 request/second (`--min-interval-ms 1000`) to respect rate limits.
- Use `--no-cover` to skip cover fetch and embedding.
- Use `--choose-release` to select a release interactively from the recording's release list.
- Use `--release-index N` to select a release non-interactively (1-based).
- Use `--release-id <MBID>` to choose a specific MusicBrainz release deterministically.
- Use `--print-release-candidates` to print release options without tagging files.
- Selection precedence: `--release-id` > `--release-index` > `--choose-release` > default first release.
- Tags written: `TITLE`, `ARTIST`, `ALBUMARTIST`, optional `ALBUM`, optional `DATE`, `MUSICBRAINZ_RECORDINGID`, optional `YOUTUBE_ID`.
