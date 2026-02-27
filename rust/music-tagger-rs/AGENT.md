# AGENT Guidelines

This project follows simple, practical Rust standards.

## Coding Rules
- Follow KISS: keep it super simple.
- Use idiomatic Rust and follow official best practices.
- Keep code simple, readable, and modular.
- Reuse existing functions, variables, and instructions whenever possible before adding new ones.
- Avoid duplicate logic; extract shared behavior into helper functions/modules.
- Prefer clear names over short or clever names.
- Run formatting and linting before finalizing changes:
  - `cargo fmt`
  - `cargo clippy --all-targets --all-features -D warnings`

## Error Handling
- Prefer `Result<T, E>` for recoverable failures.
- Avoid `unwrap()`/`expect()` in core logic unless failure is truly unrecoverable and documented.

## Source Structure (Keep It Simple)
Use this structure as the code grows:

```text
src/
  main.rs        # binary entrypoint
  app/           # application flow/orchestration
    mod.rs
  domain/        # core business rules (when needed)
  infra/         # external integrations (when needed)
  util/          # shared helpers (when needed)
```

Only create new folders/modules when needed.
