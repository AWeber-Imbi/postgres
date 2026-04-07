# postgres

Custom PostgreSQL 18 image based on the [official postgres image](https://hub.docker.com/_/postgres),
with the following extensions pre-installed:

- [Apache AGE](https://age.apache.org/) — graph database functionality
- [pg_cron](https://github.com/citusdata/pg_cron) — job scheduling
- [pgTAP](https://pgtap.org/) — unit testing
- [pgvector](https://github.com/pgvector/pgvector) — vector similarity search

The image sets `POSTGRES_USER=imbi` and `POSTGRES_DATABASE=imbi` by default, and
pre-loads `age` and `pg_cron` via `shared_preload_libraries`.

## Pulling the Image

The image is published to [GitHub Container Registry](https://ghcr.io/aweber-imbi/postgres).
Multi-architecture builds are available for `linux/amd64` and `linux/arm64`.

```bash
# Latest from main
docker pull ghcr.io/aweber-imbi/postgres:main

# Specific git tag
docker pull ghcr.io/aweber-imbi/postgres:18.3-0
```

### Use in Docker Compose

```yaml
services:
  postgres:
    image: ghcr.io/aweber-imbi/postgres:main
    environment:
      POSTGRES_PASSWORD: your-password
```

## Environment Variables

The following environment variables are supported by the base image and can be
set at runtime:

### `POSTGRES_PASSWORD`

**Required.** Sets the superuser password for PostgreSQL. Must not be empty or
undefined. Note that local connections inside the container use `trust`
authentication via Unix socket, so the password is only required for remote/host
connections.

### `POSTGRES_USER`

Used together with `POSTGRES_PASSWORD` to create a superuser with the given name.
Defaults to `postgres`. This image sets it to `imbi`.

### `POSTGRES_DB`

The name of the default database created on first startup. Defaults to the value
of `POSTGRES_USER`. This image sets `POSTGRES_DATABASE=imbi`.

### `POSTGRES_INITDB_ARGS`

Optional space-separated arguments passed to `postgres initdb`. For example,
`-e POSTGRES_INITDB_ARGS="--data-checksums"` enables data page checksums.

### `POSTGRES_INITDB_WALDIR`

Optional. Defines an alternate location for the PostgreSQL transaction log (WAL),
allowing the WAL to be stored on different storage than the main data directory.

### `POSTGRES_HOST_AUTH_METHOD`

Controls the authentication method for all host connections. Defaults to
`scram-sha-256` in PostgreSQL 14+. Setting this to `trust` will allow
passwordless access and is **not recommended** for anything other than local
development.

### `PGDATA`

Defines the data directory location. For PostgreSQL 18+, this defaults to
`/var/lib/postgresql/18/docker`.

## Docker Secrets

As an alternative to passing sensitive values through environment variables, you
can append `_FILE` to any of the following variable names and point to a file
containing the value. This is useful with
[Docker secrets](https://docs.docker.com/engine/swarm/secrets/).

Supported variables:

- `POSTGRES_PASSWORD_FILE`
- `POSTGRES_USER_FILE`
- `POSTGRES_DB_FILE`
- `POSTGRES_INITDB_ARGS_FILE`

Example:

```bash
docker run --name imbi-postgres \
  -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres-passwd \
  -d imbi/postgres
```

## Initialization Scripts (`/docker-entrypoint-initdb.d`)

To run additional initialization when the container starts for the first time,
place scripts in `/docker-entrypoint-initdb.d/`. Supported file types:

- `*.sql` — executed as the `POSTGRES_USER` superuser
- `*.sql.gz` — decompressed and executed as SQL
- `*.sh` — executed as shell scripts

Scripts are executed in sorted name order (locale default `en_US.utf8`), so
prefix filenames with numbers to control ordering (e.g., `001-schema.sql`,
`002-seed.sql`).

**Important:** Initialization scripts only run when the container starts with an
**empty data directory**. If the data directory already contains a database,
scripts in `/docker-entrypoint-initdb.d/` are skipped entirely. If a script
fails mid-initialization and the container is restarted, the partially
initialized data directory may prevent subsequent runs from re-executing the
scripts.
