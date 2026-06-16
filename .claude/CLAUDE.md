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

## Code comments
- Comments must describe the current state of the code, not its history. Never explain how
  something used to be done or what changed ("previously…", "now we…", "renamed from…").
- Don't write comments as if work is still in progress ("TODO: still need to…", "for now…",
  "temporary"). Write them as a clear description of how the code works as it stands.
- Keep comments helpful and clear — explain intent and non-obvious "why", not the obvious.
- Don't reference other files/documents in comments unless you're certain those files are
  committed together with the code. Working notes and scratch files are often temporary and
  won't exist later, so a comment pointing at them becomes a dangling reference. Files in a
  `notes-local/` directory in particular are NEVER committed — never reference them from code.

## Writing text deliverables (tickets, emails, message replies, summaries, drafts…)
- When I ask you to write any prose deliverable, ALWAYS write it to a file — never just
  print the text in the chat.
- After you finish writing the file, open it for me in IntelliJ's standalone LightEdit
  mode: run `idea -e <path>` (the `-e` flag opens a single file without loading a project).
- Use a descriptive filename and the right extension (`.md`, `.txt`, `.eml`/`.txt` for
  emails, `.textile` for Redmine tickets). Inside a repo, default to `<repo-root>/notes-local/`.
- Don't drop files directly into `notes-local/` — use a subfolder named after the ticket
  number plus a 2–4 word explanation (e.g. `notes-local/12345-auth-bug-summary/`), or, if no
  ticket is known, the current date (e.g. `notes-local/2026-06-16-auth-bug-summary/`).
- When generating text into a new file (report, summary, etc.), I'll likely want the current
  ticket number in the filename — include it when known (e.g. `12345-summary.md`).
- When I specify a tone, language style, or target audience (e.g. "easy to understand for
  someone new to the topic"), apply it silently. NEVER mention or explain the instruction in
  the generated text itself — just write to that brief.
