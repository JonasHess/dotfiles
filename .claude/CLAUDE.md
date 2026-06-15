# Global instructions (Jonas)


## Safety — non-negotiable
- NEVER run destructive commands against production: dropping/truncating/deleting
  databases, `kubectl delete` against a prod context, `rm -rf` outside the current repo.
- Treat anything in a `prod`/`production` context as read-only unless I explicitly
  say otherwise in this session. Never mutate any environment without my explicit OK.
- Connect only to local instances (localhost or `docker exec`) — never staging,
  sandbox, or production.
- Confirm before irreversible or outward-facing actions: force-push, deleting branches,
  rewriting git history, pushing to remotes, deleting cloud resources.
- Show me the command before running anything I can't easily undo.

> Real enforcement lives in `~/.claude/settings.json` permission `deny`/`ask` rules and
> hooks — this section is only the human-readable intent.

## Git & commits
- Never commit, push, or open a PR without my explicit OK — leave changes in the working tree.
- After each finished unit of work, proactively suggest a commit message
  (format: `Ref #<ticket>: <summary>`).
- Never add a `Co-Authored-By` trailer (or any "Co-Authored" line) to commit messages.

## Cross-repo context
- My repos are cloned under `~/repos/<name>`. Freely read sibling repos for cross-project
  context without asking each time.


## How I like you to work
- Be concise. Lead with the answer, then detail.
- When you mention a file, always give its full absolute path (e.g.
  `~/repos/dotfiles/.zshrc`), not just a bare filename or a path relative
  to some directory I'd have to infer. Don't assume I'm tracking which repo/dir you mean —
  spell it out every time so the path is unambiguous and clickable.
- Prefer test-driven development: write a failing test first, implement to green, then
  run the regression suite.
- Never ask me more than one question at once.
- When you ask me a question, always give a recommendation: put the recommended option
  first marked "(Recommended)", with a confidence % (~90% = very confident it's right,
  ~10% = likely a bad choice) and a one-line why (and why weaker options are worse).

## Writing text deliverables (tickets, emails, message replies, summaries, drafts…)
- When I ask you to write any prose deliverable, ALWAYS write it to a file — never just
  print the text in the chat.
- After you finish writing the file, open it for me in IntelliJ's standalone LightEdit
  mode: run `idea -e <path>` (the `-e` flag opens a single file without loading a project).
- Use a descriptive filename and the right extension (`.md`, `.txt`, `.eml`/`.txt` for
  emails, `.textile` for Redmine tickets). Inside a repo, default to `<repo-root>/notes-jhess/`.
