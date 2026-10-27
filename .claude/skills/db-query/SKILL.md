---
name: db-query
description: Get real data from a database Claude is NOT allowed to connect to. Claude writes SQL to a .sql file, the user runs it with the `dbq` command (a Docker psql client, read-only by default), and Claude reads the result file. Use whenever analysis needs real rows/counts/schema from a Postgres database you cannot access directly - never try to connect yourself.
---

# Get data from a database via dbq

I often need real data from a database to analyze a problem, but you are NOT allowed to connect
to that database. The deal: you write the SQL, I review and run it, you read the result. You
never touch the DB.

The mechanism is the `dbq` shell command (defined in `~/repos/dotfiles/.oh-my-zsh/custom/dbq.zsh`).
It runs the query with a throwaway Docker `psql` client, **read-only by default**, using
credentials I set up once per environment.

## The loop (follow it exactly)

1. **Write the query to a `.sql` file.** Never print a query for me to copy - always write a file.
   - Inside a repo, put it under the ticket folder: `notes-local/<release>/#<ticket>-<slug>/sql/`.
     For scratch with no ticket, use `notes-local/#24466-<slug>/sql/`. Outside any repo, use the
     session scratchpad directory.
   - Name files with a two-digit order prefix + a short slug: `01-orphaned-invoices.sql`,
     `02-check-fk.sql`. Keep them ordered so a sequence of queries is easy to follow.
   - Start each file with a one-line SQL comment saying what the query answers
     (`-- Count invoices with no matching order, per month`).
   - No whitespace in paths (use `_`), same as the global notes-local rules.

2. **Never run it yourself. Never connect to any database.** No psql, no docker, no MCP DB tool,
   no connection string. Running is mine alone - that is the whole point.

3. **Hand me ONE command to run**, the exact line, for example:
   ```
   dbq <env> notes-local/release_3.19/#43992-foo/sql/01-orphaned-invoices.sql
   ```
   - `<env>` is the environment name (`local`, `staging`, ...). If you don't know which
     environment to target, ASK me once and reuse my answer for the session. Never guess.
   - Leave it read-only (the default). Only add `--write` if a write is genuinely required, and
     say so explicitly and why - I still have to approve it at the prompt.
   - You do NOT need and must NOT ask for credentials: they live in
     `~/repos/dotfiles/.oh-my-zsh/custom/dbq/secret-<env>.env` and `dbq` loads them itself.

4. **I review and run.** `dbq` prints the full SQL and the target, then asks me to confirm before
   anything executes - so I always see exactly what runs. I can also open the `.sql` file first.

5. **Read the result.** `dbq` writes the output next to the query as `<same-name>.result.txt`
   (e.g. `01-orphaned-invoices.result.txt`) and prints the path. Read that file to get the data.
   If I just say "done" / "ran it", look for the `.result.txt` next to the `.sql` you wrote.

6. **Iterate.** Need more? Write the next numbered `.sql` in the same folder and hand me the next
   `dbq` command. One focused query per file beats one giant script.

## Rules

- **Read-only is the default and the norm.** Analysis queries must be read-only. `dbq` runs the
  session with `default_transaction_read_only=on`, so a stray write errors out instead of changing
  data. Treat `--write` as an exception that needs a clear reason and my explicit go-ahead.
- **Keep queries readable and safe.** Qualify schemas where it matters, avoid `SELECT *` on wide
  tables when a few columns answer the question, add `LIMIT` when sampling. Never embed secrets or
  credentials in the SQL. Be mindful that results may contain real customer/supplier data.
- **Explain what you want to learn.** When you hand me a query, say in one line what it checks and
  what you expect to see, so I can sanity-check it before running.
- **If `dbq` isn't set up for an environment**, it will tell me to create the credential file.
  Point me at `dbq --help` for the template; don't try to create or guess credentials yourself.

## One-time setup (my job, not yours)

Per environment I create `~/repos/dotfiles/.oh-my-zsh/custom/dbq/secret-<env>.env` (chmod 600).
The name starts with `secret`, which is what keeps it gitignored - credential files are never
committed. Each holds `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`, and optionally
`DBQ_IMAGE` to pin a Postgres version. For a database running on my Mac,
`PGHOST=host.docker.internal` so the Docker client can reach it. `dbq --list` shows what's
configured.
