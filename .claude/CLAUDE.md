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
- Treat Redmine as a production environment — be very careful about what you change there.
  Reading is fine, but EVERY write operation (creating/updating/closing tickets, editing
  fields, adding comments, changing status/assignee, etc.) must be reviewed and explicitly
  approved by me before you execute it. Show me exactly what you intend to write first.

> Real enforcement lives in `~/.claude/settings.json` permission `deny`/`ask` rules and
> hooks — this section is only the human-readable intent.

## Git & commits
- Never commit, push, or open a PR without my explicit OK — leave changes in the working tree.
- After each finished unit of work, proactively suggest a commit message. Format:
  `Ref #<ticket> <very short ticket description> - <what changes in this commit>`
  (e.g. `Ref #43134 mixed VAT rounding - fix cent rounding on split invoices`). Only the
  part after ` - ` describes this specific commit.
- The `Ref #<ticket> <very short ticket description>` prefix must stay STABLE across all of a
  ticket's commits — don't reword it each time. Before writing a commit for a ticket, look at
  that ticket's existing commits (e.g. `git log --grep "#<ticket>"`) and reuse the exact same
  prefix verbatim. Only change it if there's a good reason (e.g. the current wording is wrong
  or misleading), and say why when you do.
- Keep commit messages you generate to a single line (the subject only) — no body, no bullet
  list. Keep that line short and to the point (aim for ~72 characters); summarize, don't list
  every change. If a change feels too big for one short line, that's a signal to split it into
  smaller commits. Exceptions: mechanical multi-line messages you don't author, like merge
  commits and reverts.
- Never add a `Co-Authored-By` trailer (or any "Co-Authored" line) to commit messages.

## Working in a git repository
- The first time a conversation touches code in an existing git repo, check which
  branch we're on before reading or writing code — we want to avoid working on the
  wrong branch.
- Never switch, create, or reset branches yourself without my explicit OK.
- If you suspect we're on the wrong branch (e.g. a feature branch when the task is
  for a different ticket, `main`/`master` when I'd expect a working branch) or that
  the branch is behind its remote, STOP and warn me before continuing. Let me decide
  whether to switch or pull.

## Cross-repo context
- My repos live under `~/repos/<name>` OR `~/IdeaProjects/<name>`, depending on the machine
  (this config is shared across two setups). A given repo may exist in only one of them, so
  when locating a sibling repo, check both roots and use whichever actually exists — don't
  assume `~/repos`. Freely read sibling repos for cross-project context without asking each time.


## VPN / network reachability
- If a server that should be reachable is not (e.g. GitLab, internal Git remotes,
  internal APIs/registries) — connection refused, timeout, DNS failure, host not
  found — it is very likely because the corporate VPN client is not connected.
- In that case, STOP what you're doing. Don't retry blindly, work around it, or
  switch to an alternate host. Tell me the server looks unreachable, that it's
  probably the VPN, and ask me to reconnect the VPN before you continue.

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

## Response format
Structure every non-trivial response so I can catch up fast. Skip all of this on trivial
one-line replies (a bare "Done" doesn't need a TL;DR or a footer).

- **TL;DR at the top.** Open with a blockquoted H3 that summarizes the whole response in
  1–2 sentences:

  ```
  > ### 📌 TL;DR
  > One or two sentences.
  ```

- **Body.** Then the actual answer.

- **Footer block at the bottom.** After the answer, add a `---` divider, then:
  - `💾 **Commit:**` — a ready-to-use commit message in the format above
    (`Ref #<ticket> <very short ticket description> - <what changes in this commit>`),
    shown *only* when the working tree has uncommitted changes (omit the line entirely when
    it's clean). Check working-tree state only when changes plausibly exist — not on pure
    Q&A. This satisfies the "proactively suggest a commit message" rule above and keeps a
    ready message in front of me whenever the tree is dirty.
    - Don't assume your session memory reflects the real git state — I may have committed
      between turns. Re-check with `git status` periodically, and *always* before you
      actually suggest committing. No need to check on every response, but don't let it go
      stale. Base the message only on genuinely uncommitted changes; if the tree is clean,
      show no 💾 line.
  - `❓ **<question>?**` — frame this as a real question: summarize the pending decision as
    the question (e.g. `❓ **Commit it now?**`), or if nothing is pending, ask what the next
    step should be (e.g. `❓ **Next step?**`). Follow it with my likely answers as
    plain-numbered, first-person, pickable options so I can just reply `1`, each with a
    rough likelihood %. Give two by default (occasionally a third when a genuinely distinct
    one exists), leaning in different directions.

- Use exactly one emoji per line as above (📌 / 💾 / ❓) and plain numbers (`1.`, `2.`) for
  the options — no other decoration. In-terminal rendering has no color, so the blockquote
  heading, the divider, and these markers are what set the blocks apart; keep them
  consistent.

- The ❓ predictions are separate from the `(Recommended)` + confidence-% rule above. When a
  response ends with a real decision, keep that recommendation in the prose *and* give the
  pickable predictions in the footer — fold them together when they agree, but still surface
  the opposing direction.

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
  emails; Redmine tickets are Markdown, so `.md`). Inside a repo, default to `<repo-root>/notes-local/`.
- Organize `notes-local/` by release, then by ticket:
  `notes-local/<release>/#<ticket>-<slug>/<files>`, e.g.
  `notes-local/release 3.18/#43134-mixed-vat/assessment.md`.
  - `<release>` is the top-level folder (e.g. `release 3.18`). If I haven't told you the
    release and you can't infer it, ASK me which release before creating the folder.
  - The ticket folder is `#<ticket>-<slug>` (`#` + ticket number + 2–4 word slug). Three cases:
    - **Known ticket number:** use it, e.g. `#43134-mixed-vat`.
    - **Drafting a NEW ticket whose number isn't known yet:** use `#NEW-<slug>` (e.g.
      `#NEW-mixed-vat`) and `Ref #NEW` in the draft — NEVER invent a number and NEVER use
      `#24466` for this. `#NEW` means "real ticket, number still unknown." Actively remind me
      each time that I haven't given you the ticket number yet. Once I tell you the real
      number, rename the folder and replace every `#NEW` (filenames + content) with it right
      away. `#NEW` must NEVER remain in content that goes into Redmine.
    - **Scratch/analysis that will never become a ticket:** use `#24466-<slug>` — locally
      `#24466` is the "no real ticket" marker. `#24466` must NEVER appear in real Redmine
      ticket content, and must NEVER be used as a placeholder for a ticket you're drafting
      (that's what `#NEW` is for).
  - Files *inside* that folder get plain, simple names — don't repeat the ticket number
    (e.g. `summary.md`, `assessment.md`, `logs/`).
- When I specify a tone, language style, or target audience (e.g. "easy to understand for
  someone new to the topic"), apply it silently. NEVER mention or explain the instruction in
  the generated text itself — just write to that brief.

## Ticket knowledgebase (mandatory)
- This whole section applies only to **real tickets**. `#24466` (the "no real ticket"
  marker) is EXCLUDED — don't auto-search for or auto-create a knowledgebase for it. A
  knowledgebase under `#24466-*` is only made if I explicitly ask.
- Whenever we work on a real ticket, you MUST keep a per-ticket knowledgebase as a Markdown
  file in `notes-local/`. Use the same layout as above:
  `notes-local/<release>/#<ticket>-<slug>/knowledgebase.md`.
- Create it as soon as we start on a ticket if it doesn't exist yet. From then on, keep it
  updated **on your own, without being asked** — refresh it along the way as you learn
  things, make decisions, or change the plan. Don't wait until the end.
- This file is the key reference for starting NEW conversations on the same ticket. Write
  it so a future Claude with no memory of this session can get up to speed fast. It should
  work as an **index**: point to the relevant code (full paths + symbols), other
  `notes-local/` files, tickets/MRs, logs, and commands — so the next conversation knows
  where to go to gather information rather than rediscovering it.
- Good contents: the goal/ticket summary, current status, key findings, decisions made and
  why, open questions, what's been tried, next steps, and the pointers/index described
  above.
- This file is a working note and is **NEVER committed** (it lives in `notes-local/`, which
  is git-ignored). Because it won't be committed, it MAY freely reference other local files
  and paths — the "don't reference other files" rule for code comments does not apply here.
- When we start on a real ticket, fetch its current information from Redmine via the
  Redmine MCP on your own, without being asked (this is a read, which is always allowed —
  only Redmine *writes* need my approval). Use it to ground the knowledgebase and your
  understanding, and refresh it if the ticket may have changed since you last looked.
- It is YOUR responsibility to find an existing knowledgebase before starting work — don't
  wait for me to point you to it. As soon as a ticket comes up, search `notes-local/`
  across releases for a matching `#<ticket>-*` folder / `knowledgebase.md` (the ticket may
  be filed under a release folder you don't expect, so search broadly, not just one path).
  If you find one, read it before doing anything else. If you don't, create a fresh one.
