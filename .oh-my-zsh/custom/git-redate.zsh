# git-redate — interactively rewrite commit dates.
#
# Dumps recent commits (date | hash | subject) into a temp file, opens it in your
# editor so you can change the dates, then rewrites history with those dates via
# git filter-branch. Type `now` as a date to use the current timestamp.
#
# Usage: git-redate [-c N|--commits N] [-a|--all] [-l N|--limit N] [-d|--debug]
#   -c/--commits N : how many commits back to edit (default 5; ignored with --all)
#   -a/--all       : rewrite every commit on all refs
#   -l/--limit N   : commits per filter-branch chunk (default 20)
#   -d/--debug     : verbose progress output
#
# The chosen editor is remembered in ~/.redate-settings (falls back to $VISUAL/$EDITOR).
# After it runs, push with: git push -f <branch>

git-redate() {
    emulate -L zsh
    setopt local_options no_nomatch

    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        print -u2 'Not a git repo!'
        return 1
    fi

    local all=0 debug=0 limitchunks=20 commits=5
    while (( $# )); do
        case "$1" in
            -c|--commits) commits="${2:-5}";      shift 2 2>/dev/null || shift ;;
            -l|--limit)   limitchunks="${2:-20}"; shift 2 2>/dev/null || shift ;;
            -d|--debug)   debug=1; shift ;;
            -a|--all)     all=1;   shift ;;
            *)            shift ;;
        esac
    done

    # Resolve the editor: saved choice, then $EDITOR, else ask and remember.
    local settings_file="$HOME/.redate-settings"
    local our_editor
    if [[ -f "$settings_file" ]]; then
        our_editor="$(<"$settings_file")"
    elif [[ -n "$EDITOR" ]]; then
        our_editor="$EDITOR"
    else
        print "Which editor do you want to use for this repo?"
        print "  1. vi"
        print "  2. nano"
        print "  3. Your own"
        print -n "You choose: "
        local choice; read -r choice
        case "$choice" in
            3) print -n "Path to your preferred editor: "; read -r our_editor ;;
            1) our_editor="vi" ;;
            *) our_editor="nano" ;;
        esac
        print -r -- "$our_editor" > "$settings_file"
    fi

    # Prefer strict ISO dates (%cI); fall back to %ci on older git that echoes the literal.
    local datefmt='%cI'
    if [[ "$(git log -n1 --pretty=format:"$datefmt")" == "$datefmt" ]]; then
        datefmt='%ci'
    fi

    local tmpfile
    tmpfile="$(mktemp "${TMPDIR:-/tmp}/git-redate-XXXXXX")" || {
        print -u2 'git-redate: could not create temp file'
        return 1
    }

    {
        if (( all )); then
            git log --pretty=format:"$datefmt | %H | %s" > "$tmpfile"
        else
            git log -n "$commits" --pretty=format:"$datefmt | %H | %s" > "$tmpfile"
        fi

        # Let the user edit the dates in place.
        ${VISUAL:-${EDITOR:-$our_editor}} "$tmpfile"

        # Build one sh env-filter snippet per commit, batched into chunks so a single
        # filter-branch invocation doesn't get an enormous --env-filter.
        local -a chunks
        local iter=0 idx date hash message date_nospace commit_env
        local countcommits
        countcommits="$(grep -c '' "$tmpfile")"

        while IFS='|' read -r date hash message || [[ -n "$date" ]]; do
            # Trim whitespace the '|' split left around the fields.
            date="${date#"${date%%[![:space:]]*}"}"
            date="${date%"${date##*[![:space:]]}"}"
            hash="${hash//[[:space:]]/}"
            [[ -z "$hash" ]] && continue

            if [[ "${date:l}" == 'now' ]]; then
                date="$(date +%Y-%m-%dT%H:%M:%S%z)"
            fi
            # %cI carries no spaces; strip any for safety. %ci keeps its internal spaces.
            if [[ "$datefmt" == '%cI' ]]; then
                date_nospace="${date//[[:space:]]/}"
            else
                date_nospace="$date"
            fi

            commit_env='if test "$GIT_COMMIT" = "'"$hash"'"; then'
            commit_env+=' export GIT_AUTHOR_DATE="'"$date_nospace"'";'
            commit_env+=' export GIT_COMMITTER_DATE="'"$date_nospace"'";'
            commit_env+=' fi; '

            (( iter++ ))
            idx=$(( (iter - 1) / limitchunks + 1 ))    # zsh arrays are 1-based
            chunks[$idx]+="$commit_env"
            (( debug )) && print "Commit $iter/$countcommits collected"
        done < "$tmpfile"

        if (( ${#chunks} == 0 )); then
            print -u2 'git-redate: nothing to do.'
            return 1
        fi

        # filter-branch is noisy and deprecated but does the job; hush its nag.
        local FILTER_BRANCH_SQUELCH_WARNING=1
        export FILTER_BRANCH_SQUELCH_WARNING

        local it=0 total=${#chunks} each
        local -a fbargs
        if (( all )); then
            fbargs=(-- --all)
        else
            # HEAD~N points before the root when N covers the whole history, which
            # filter-branch rejects — rewrite from the root (HEAD) in that case.
            local total_commits
            total_commits="$(git rev-list --count HEAD 2>/dev/null)"
            if [[ -n "$total_commits" ]] && (( commits >= total_commits )); then
                fbargs=(HEAD)
            else
                fbargs=("HEAD~${commits}..HEAD")
            fi
        fi

        for each in "${chunks[@]}"; do
            (( it++ ))
            (( debug )) && print "Chunk $it/$total started"
            if (( debug )); then
                git filter-branch -f --env-filter "$each" "${fbargs[@]}"
            else
                git filter-branch -f --env-filter "$each" "${fbargs[@]}" >/dev/null 2>&1
            fi
            if (( $? != 0 )); then
                print -u2 "git-redate failed. Run it on a clean working directory."
                return 1
            fi
            (( debug )) && print "Chunk $it/$total finished"
        done

        print "Git commit dates updated. Run 'git push -f <branch>' to push your changes."
    } always {
        rm -f "$tmpfile"
    }
}
