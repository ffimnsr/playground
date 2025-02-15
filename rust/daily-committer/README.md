# Daily Committer

An application that automates daily Git commits by updating a timestamp in README files.

## Features

- Automated daily Git commits
- SSH authentication support
- Configurable commit scheduling
- Timestamp-based README updates

## Installation

Ensure you have Rust and Cargo installed, then:

```sh
cargo build --release
```

## Usage

The application requires a Git repository with SSH access configured. It will:

- Update the README.md with the current timestamp
- Create a commit
- Push changes to the remote repository

## Configuration

The application uses environment variables for configuration:

- Set up your Git credentials
- Configure SSH access for automated pushes

## License

This project is dual-licensed under:

- Apache License, Version 2.0
- MIT License

Choose the license that best suits your needs.

