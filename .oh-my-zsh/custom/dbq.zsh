# dbq - run a reviewed SQL file against Postgres via a throwaway Docker psql client.
#
# The workflow: Claude writes a .sql file, you review and run it with ONE command, Claude
# reads the result. Nothing touches a database until you confirm. Credentials live once per
# environment in .oh-my-zsh/custom/dbq/secret-<env>.env - every credential file name starts
# with "secret" and is gitignored, so it can never be committed. Postgres runs from a Docker
# image, so you are free to use any server version (set DBQ_IMAGE per env).
#
# Usage:
#   dbq <env> <file.sql> [--write] [--yes] [--image IMG]
#   dbq --list
#   dbq --help
#
# Result is written next to the SQL file as <file>.result.txt and also printed.

dbq() {
  local cfg_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/dbq"

  if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
    cat <<'EOF'
dbq - run a reviewed SQL file against Postgres via a Docker psql client (read-only by default).

Usage:
  dbq <env> <file.sql> [--write] [--yes] [--image IMG]
  dbq --list
  dbq --help

  <env>        environment name; reads .oh-my-zsh/custom/dbq/secret-<env>.env
  <file.sql>   SQL file to run (Claude writes it; you review it)
  --write      allow writes (default is a read-only session; any write errors out)
  --yes, -y    skip the confirmation prompt (for trusted re-runs)
  --image IMG  Postgres image to use (default: $DBQ_IMAGE or postgres:17-alpine)

Result is written next to the SQL file as <file>.result.txt and printed.

One-time setup per environment - create ~/.oh-my-zsh/custom/dbq/secret-<env>.env (chmod 600).
The name MUST start with "secret" (that is what keeps it gitignored). Contents:
  PGHOST=host.docker.internal   # reaches a DB on your Mac from inside Docker
  PGPORT=5432
  PGDATABASE=mydb
  PGUSER=myuser
  PGPASSWORD=secret
  # optional: DBQ_IMAGE=postgres:16-alpine
EOF
    return 0
  fi

  if [[ "$1" == "--list" ]]; then
    if [[ -d "$cfg_dir" ]]; then
      echo "Configured dbq environments (in $cfg_dir):"
      local f found=0
      for f in "$cfg_dir"/secret-*.env(N); do echo "  - ${${f:t:r}#secret-}"; found=1; done
      (( found )) || echo "  (none yet - create secret-<env>.env; see: dbq --help)"
    else
      echo "No environments yet. Create ${cfg_dir}/secret-<env>.env (see: dbq --help)."
    fi
    return 0
  fi

  local env="$1"; shift
  local sqlfile="" image="${DBQ_IMAGE:-postgres:17-alpine}"
  local write=0 assume_yes=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --write) write=1; shift ;;
      --yes|-y) assume_yes=1; shift ;;
      --image) image="$2"; shift 2 ;;
      -*) echo "dbq: unknown option: $1"; return 1 ;;
      *) if [[ -z "$sqlfile" ]]; then sqlfile="$1"; shift
         else echo "dbq: unexpected argument: $1"; return 1; fi ;;
    esac
  done

  if [[ -z "$sqlfile" ]]; then echo "dbq: missing SQL file. See: dbq --help"; return 1; fi
  if [[ ! -f "$sqlfile" ]]; then echo "dbq: SQL file not found: $sqlfile"; return 1; fi

  local cfg="$cfg_dir/secret-$env.env"
  if [[ ! -f "$cfg" ]]; then
    echo "dbq: no config for env '$env' at $cfg (create it, chmod 600 - see: dbq --help)"
    if [[ -d "$cfg_dir" ]]; then
      local f; echo "Available:"; for f in "$cfg_dir"/secret-*.env(N); do echo "  - ${${f:t:r}#secret-}"; done
    fi
    return 1
  fi

  # Keep credentials function-local so they never leak into the interactive shell's environment.
  local PGHOST PGPORT PGDATABASE PGUSER PGPASSWORD
  source "$cfg"
  : "${PGPORT:=5432}"
  if [[ -z "$PGHOST" || -z "$PGDATABASE" || -z "$PGUSER" ]]; then
    echo "dbq: $cfg must set at least PGHOST, PGDATABASE, PGUSER"; return 1
  fi

  local mode="READ-ONLY"
  (( write )) && mode="WRITE ENABLED"

  echo "------------------------------------------------------------"
  echo "dbq: about to run SQL against environment '$env'"
  echo "  target : $PGUSER@$PGHOST:$PGPORT/$PGDATABASE"
  echo "  image  : $image"
  echo "  mode   : $mode"
  echo "  file   : $sqlfile"
  echo "------------------------------------------------------------"
  echo "----- SQL -----"
  cat "$sqlfile"
  echo "---------------"
  if (( ! assume_yes )); then
    local reply
    if (( write )); then echo -n "Run this in WRITE mode against '$env'? [y/N] "
    else echo -n "Run this (read-only) against '$env'? [y/N] "; fi
    read -r reply
    if [[ "$reply" != "y" && "$reply" != "Y" ]]; then echo "dbq: aborted."; return 1; fi
  fi

  local resultfile="${sqlfile:r}.result.txt"
  {
    echo "-- dbq result"
    echo "-- env    : $env  ($mode)"
    echo "-- target : $PGUSER@$PGHOST:$PGPORT/$PGDATABASE"
    echo "-- image  : $image"
    echo "-- run at : $(date '+%Y-%m-%d %H:%M:%S')"
    echo "-- query  : $sqlfile"
    echo
  } > "$resultfile"

  # Read-only by default: a server-side session GUC so any INSERT/UPDATE/DELETE/DDL errors out.
  local -a pgopts
  (( ! write )) && pgopts=(-e "PGOPTIONS=-c default_transaction_read_only=on")

  docker run --rm -i \
    -e "PGHOST=$PGHOST" -e "PGPORT=$PGPORT" -e "PGDATABASE=$PGDATABASE" \
    -e "PGUSER=$PGUSER" -e "PGPASSWORD=$PGPASSWORD" \
    "${pgopts[@]}" \
    "$image" \
    psql -v ON_ERROR_STOP=1 -P pager=off -f - < "$sqlfile" 2>&1 | tee -a "$resultfile"
  local rc=${pipestatus[1]}

  echo
  if (( rc == 0 )); then echo "dbq: done. Result: $resultfile"
  else echo "dbq: psql exited with status $rc (see $resultfile)"; fi
  return $rc
}
