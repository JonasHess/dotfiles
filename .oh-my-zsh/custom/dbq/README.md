# dbq environment credentials

One file per environment, named `secret-<env>.env` (e.g. `secret-local.env`,
`secret-staging.env`). The name MUST start with `secret` - that prefix is what keeps the file
gitignored (see the `/.oh-my-zsh/custom/dbq/secret*` rule in the repo `.gitignore`), so a
credential file can never be committed. This README does not start with `secret`, so it stays
tracked as documentation.

Create one, then `chmod 600` it:

```
PGHOST=host.docker.internal   # reaches a DB on this Mac from inside Docker
PGPORT=5432
PGDATABASE=mydb
PGUSER=myuser
PGPASSWORD=secret
# optional: pin a Postgres version for the throwaway psql client
# DBQ_IMAGE=postgres:16-alpine
```

Then run a query file:

```
dbq local path/to/query.sql          # read-only (default)
dbq local path/to/query.sql --write  # allow writes (asks again)
dbq --list                           # list configured environments
dbq --help
```

Results are written next to the query as `<query>.result.txt`.

Notes:
- `host.docker.internal` is how a Docker container reaches a server listening on this Mac. For a
  DB in docker-compose, make sure its port is published to the host.
- Read-only mode sets `default_transaction_read_only=on` for the session, so writes error out.
- `dbq` is defined in `~/repos/dotfiles/.oh-my-zsh/custom/dbq.zsh`.
