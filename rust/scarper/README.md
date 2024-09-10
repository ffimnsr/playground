# Scarper

[![Crates.io](https://img.shields.io/crates/v/scarper?style=flat-square)](https://crates.io/crates/scarper)
[![Crates.io](https://img.shields.io/crates/l/scarper?style=flat-square)](https://crates.io/crates/scarper)
[![Crates.io](https://img.shields.io/crates/d/scarper?style=flat-square)](https://crates.io/crates/scarper)

> Bypasses are devices that allow some people to dash from point A to point B
> very fast while other people dash from point B to point A very fast. People
> living at point C, being a point directly in between, are often given to
> wonder what's so great about point A that so many people from point B are so
> keen to get there, and what's so great about point B that so many people
> from point A are so keen to get there. They often wish that people would
> just once and for all work out where the hell they wanted to be.
> - from The Hitchhiker's Guide to the Galaxy, Douglas Adams

Manage your `.local\bin` without sweat.

## Usage

### Using CLI

Here is a sample command line usage of `scarper`.

```bash
$ scarper
```

Create a `scarper_watch.toml` and put your package to be version check.
See [scarper_watch.toml](scarper_watch.toml) for an example.

## Installation

If you're into **Rust** then you can use `cargo` to install.

* The minimum supported version of Rust is 1.41.0.

```bash
$ cargo install scarper
```

Binary format for different OS distribution can be downloaded [here](https://github.com/ffimnsr/scarper-rs/releases).

## What's in the Roadmap

- [ ] Add custom path for the watch config file.
- [ ] Add more plugins.
- [ ] More to come.

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or
  http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
