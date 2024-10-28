Changing the `wal_level` to `logical`:

```bash
ALTER SYSTEM SET wal_level = logical;
SELECT pg_reload_conf();
```

The `pg_reload_conf()` acts as a restart database. In this scenario you don't need to edit the `postgresql.conf` file in docker images.

I've use this config in `logflare`.

#### References:
- https://www.postgresql.org/docs/current/sql-altersystem.html
