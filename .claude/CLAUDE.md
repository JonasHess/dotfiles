# Global instructions (Jonas)


## Safety - non-negotiable
- NEVER run destructive commands against production: dropping/truncating/deleting
  databases, `kubectl delete` against a prod context, `rm -rf` outside the current repo.
- Treat anything in a `prod`/`production` context as read-only unless I explicitly
  say otherwise in this session. Never mutate any environment without my explicit OK.
- Connect only to local instances (localhost or `docker exec`) - never staging,
  sandbox, or production.
- Confirm before irreversible or outward-facing actions: force-push, deleting branches,
  rewriting git history, pushing to remotes, deleting cloud resources.
- Show me the command before running anything I can't easily undo.
- Always target the environment EXPLICITLY - never rely on whatever "current"/default context
  happens to be selected, so we can't act on the wrong one by mistake. For `kubectl`, always
  pass an explicit `--context` (and `--namespace` where it matters); never depend on the
  current context. Do the same for other environment-scoped tools, especially cloud CLIs:
  `gcloud --project`/`--account`, `aws --profile`/`--region`, `az --subscription`, `docker
  context`/`-H`, `helm --kube-context`, etc. If you don't know which context/project to use,
  ASK - don't guess. And per the rules above, prod contexts stay read-only unless I say
  otherwise.
- Treat Redmine as a production environment - be very careful about what you change there.
  Reading is fine, but EVERY write operation (creating/updating/closing tickets, editing
  fields, adding comments, changing status/assignee, etc.) must be reviewed and explicitly
  approved by me before you execute it. Show me exactly what you intend to write first.

- **Approval is always per-action and one-time, never standing.** For ANY critical, irreversible,
  or outward-facing action - commits, pushes, force-pushes, deleting branches, rewriting history,
  Redmine writes, deleting cloud resources, destructive/DB commands, mutating any environment,
  etc. - my OK covers only that one action. A previous "yes" is NEVER blanket consent to do it
  again. Ask me fresh and get explicit go-ahead before EVERY such action, no matter how many
  I've already approved this session. When unsure whether something crosses this line, treat it
  as if it does and ask.

> Real enforcement lives in `~/.claude/settings.json` permission `deny`/`ask` rules and
> hooks - this section is only the human-readable intent.

## Git & commits
- Never commit, push, or open a PR without my explicit OK - leave changes in the working tree.
  This approval is **per-commit and one-time**: my OK for one commit does NOT grant standing
  permission for later ones. ALWAYS ask and get my explicit go-ahead again before EACH
  commit, no matter how many I've already approved this session. Never treat a previous "yes"
  as blanket consent to keep committing on my behalf.
- After each finished unit of work, proactively suggest a commit message. First pick the
  message **profile** by looking at the repo's existing history - inspect `git log` and match
  the style that's already there. The controlled profile set (currently two):
  - **Ticketed** - repos related to **pubx** or **mvb** (and any repo whose history uses
    `Ref #<ticket>` prefixes):
    `Ref #<ticket> <very short ticket description> - <what changes in this commit>`
    (e.g. `Ref #43134 mixed VAT rounding - fix cent rounding on split invoices`).
  - **Default (fallback)** - every other repo (dotfiles, smarthome, mac-setup, …); no ticket
    number: `<scope> - <what changes in this commit>`
    (e.g. `claude config - keep commit subjects short`).
  In both, only the part after ` - ` describes this specific commit; the part before ` - ` is a
  stable label (the `Ref #<ticket> <desc>` or the `<scope>`).
- Keep that label before ` - ` STABLE across a repo's / ticket's commits - don't reword it each
  time. Before committing, look at existing commits (`git log`, or `git log --grep "#<ticket>"`
  for ticketed repos) and reuse the same label verbatim. Only change it for a good reason (the
  wording is wrong or misleading), and say why when you do.
- Keep commit messages you generate to a single line (the subject only) - no body, no bullet
  list. Keep that line short and to the point (aim for ~72 characters); summarize, don't list
  every change. If a change feels too big for one short line, that's a signal to split it into
  smaller commits. Exceptions: mechanical multi-line messages you don't author, like merge
  commits and reverts.
- I sometimes reword commit messages by hand. Before you amend or otherwise rewrite an
  existing commit's message (`git commit --amend`, rebase reword, etc.), check the commit's
  current message first (e.g. `git log -1 --format=%B`). If it differs from what you last wrote
  - i.e. I've reworded it - do NOT blindly overwrite it: preserve my wording, or ask me before
  changing it. Amending to add staged changes is fine, but keep my message unless I say
  otherwise.
- Never add a `Co-Authored-By` trailer (or any "Co-Authored" line) to commit messages.

## Working in a git repository
- The first time a conversation touches code in an existing git repo, check which
  branch we're on before reading or writing code - we want to avoid working on the
  wrong branch.
- Never switch, create, or reset branches yourself without my explicit OK.
- If you suspect we're on the wrong branch (e.g. a feature branch when the task is
  for a different ticket, `main`/`master` when I'd expect a working branch) or that
  the branch is behind its remote, STOP and warn me before continuing. Let me decide
  whether to switch or pull.
- **Working with tags is high-risk - be extra careful.** When creating a branch from a tag,
  moving/re-pointing a tag, or anything else involving tags:
  - Make sure we're on the up-to-date state from origin first (`git fetch --tags` / check
    against origin) - never act on a stale local view of tags or branches.
  - Never delete, move, or overwrite other tags by accident. Touch only the exact tag we
    agreed on; double-check the tag name and target commit before acting.
  - Be aware that tags (and pushes) can trigger CI/CD pipelines. If there's any chance an
    action triggers a pipeline, ASK me first and WAIT for my decision - don't risk it.
  - NEVER push tags or branches yourself. Prepare the change locally, show me the exact
    commands, and either ask me to run the push or wait for my explicit approval. This is a
    per-action approval (see Safety) - a previous OK never carries over.

## Cross-repo context
- My repos live under `~/repos/<name>` OR `~/IdeaProjects/<name>`, depending on the machine
  (this config is shared across two setups). A given repo may exist in only one of them, so
  when locating a sibling repo, check both roots and use whichever actually exists - don't
  assume `~/repos`. Freely read sibling repos for cross-project context without asking each time.


## VPN / network reachability
- If a server that should be reachable is not (e.g. GitLab, internal Git remotes,
  internal APIs/registries) - connection refused, timeout, DNS failure, host not
  found - it is very likely because the corporate VPN client is not connected.
- In that case, STOP what you're doing. Don't retry blindly, work around it, or
  switch to an alternate host. Tell me the server looks unreachable, that it's
  probably the VPN, and ask me to reconnect the VPN before you continue.

## Local dev testing & logs
- When you test or exercise anything against my local dev environment, always try to find and
  read the relevant application logs afterwards, and actively look for errors, warnings, and
  stack traces - don't just trust that a request "looked fine." Surface anything suspicious you
  find, even if the feature seemed to work.
- Learn where each application writes its logs and REMEMBER it, so you can find them faster
  next time. Save the log location(s) per application to your persistent memory (a `reference`
  memory keyed by app name) once you've confirmed them, and check that memory first before
  hunting for logs again.

## How I like you to work
- Be concise. Lead with the answer, then detail.
- When you mention a file, always give its full absolute path (e.g.
  `~/repos/dotfiles/.zshrc`), not just a bare filename or a path relative
  to some directory I'd have to infer. Don't assume I'm tracking which repo/dir you mean;
  spell it out every time so the path is unambiguous and clickable.
- Prefer test-driven development: write a failing test first, implement to green, then
  run the regression suite.
- When referring to a Merge Request, identify it by its **full title** and the **tickets and
  branches it touches** (source → target branch, related ticket number) - that's what matters
  to me. The MR's numeric ID is mostly irrelevant: you may include it, but never use the bare
  ID as the primary way to refer to an MR.
- Never use an em dash (the `U+2014` character) anywhere: not in files you write or edit, and
  not in the text you write to me. Use a regular hyphen, a colon, parentheses, or split the
  sentence instead.
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
  - `💾 **Commit:**` - a ready-to-use commit message in the right profile for the repo (see
    the profile rules above - ticketed for pubx/mvb, `<scope> - <change>` otherwise),
    shown *only* when the working tree has uncommitted changes (omit the line entirely when
    it's clean). Check working-tree state only when changes plausibly exist - not on pure
    Q&A. This satisfies the "proactively suggest a commit message" rule above and keeps a
    ready message in front of me whenever the tree is dirty.
    - Don't assume your session memory reflects the real git state - I may have committed
      between turns. Re-check with `git status` periodically, and *always* before you
      actually suggest committing. No need to check on every response, but don't let it go
      stale. Base the message only on genuinely uncommitted changes; if the tree is clean,
      show no 💾 line.
  - `❓ **<question>?**` - frame this as a real question: summarize the pending decision as
    the question (e.g. `❓ **Commit it now?**`), or if nothing is pending, ask what the next
    step should be (e.g. `❓ **Next step?**`). Follow it with my likely answers as
    first-person, pickable options, each with a rough likelihood %. Give two by default
    (occasionally a third when a genuinely distinct one exists), leaning in different
    directions.
  - **Label options with a unique per-question prefix**, NOT bare `1./2.`. Each question gets
    its own letter, and options are `<Letter><number>` - `A1`, `A2`, `A3` for one question,
    `B1`, `B2` for the next, then `C1`… Advance the letter on every new question (look at the
    letter you used last and increment; wrap around after the last usable letter). **Skip
    letters that are easy to confuse** with digits or each other - at least `I` (looks like 1)
    and `O` (looks like 0); prefer clearly distinct letters. This way when I answer with a code
    like `B2` it's unambiguous which question I'm answering - bare numbers get confused across
    turns. Example:
    ```
    ❓ **Commit it now?**
    C1. "Yes, commit it." (~70%)
    C2. "No, leave it in the working tree." (~30%)
    ```

- Use exactly one emoji per line as above (📌 / 💾 / ❓) and the `<Letter><number>` option
  labels described above - no other decoration. In-terminal rendering has no color, so the
  blockquote heading, the divider, and these markers are what set the blocks apart; keep them
  consistent.

- The ❓ predictions are separate from the `(Recommended)` + confidence-% rule above. When a
  response ends with a real decision, keep that recommendation in the prose *and* give the
  pickable predictions in the footer - fold them together when they agree, but still surface
  the opposing direction.

## Tracking multiple problems - keep my cognitive load low
I often juggle several conversations and jump between them, so I lose track of which problem
we're on and what else is open. Help me by never letting more than one problem be active at
once, and by keeping the open set visible.

- **One active problem at a time.** Only one problem is ever active. You MAY dive straight into
  a new problem when it surfaces - that's fine - as long as you're transparent: say clearly
  which problem is now active and keep the open-problems list accurate. Never switch silently.
- **Park what you're not working.** Every problem that isn't the active one is captured in the
  list (so nothing is lost) but stays out of the way. On any switch, give a one-line recap of
  the problem now being worked.
- **Name problems with short, unique handles**, not numbers - stable kebab-case handles (e.g.
  `vat-rounding`, `log-noise`) that I can reference to switch (\"do log-noise now\"). Reuse the
  same handle across turns; drop it once the problem is resolved.
- **Show an open-problems list in the footer** (in the bottom block, above the ❓ question),
  but ONLY when 2 or more problems are open; with a single problem, show nothing. Vertical,
  minimal, one emoji only on the active line.
- **Visualize blocking hierarchically.** When one problem blocks another, nest the blocker
  under the goal it blocks (goal on top, blocker indented beneath as a sub-problem that must
  clear first). Nest deeper if a blocker is itself blocked. Standalone parked problems stay
  flat. The active problem (🟢) sits wherever the work actually is - usually the deepest
  blocker. When a node resolves, drop it and its parent unblocks. Example:
  ```
  Open problems:
  - vat-rounding (blocked)
    └ 🟢 db-migration (active) - must finish first
  - log-noise (parked)
  ```
  Deeper chain:
  ```
  Open problems:
  - vat-rounding (blocked)
    └ db-migration (blocked)
      └ 🟢 fix-connection-pool (active)
  ```
  Active line gets 🟢; other lines are plain `-`/`└`. Keep handles stable; remove resolved ones.

## Writing code - follow existing patterns
- When writing or changing code (especially Java), match the patterns already established in
  the project rather than introducing your own style. Before adding code, look at how the
  surrounding code and similar existing classes do it, and follow that.
- Concretely, mirror the project's conventions for: logging (which logger/framework, how
  loggers are declared, log levels and message style), class/interface/method/variable naming,
  package structure and where new classes go, error/exception handling, dependency injection,
  test structure, formatting, and use of existing helpers/utilities instead of reinventing them.
- Prefer reusing existing abstractions and utilities over writing new ones. If the established
  pattern seems wrong or you think a different approach is clearly better, say so and ask before
  diverging - don't silently introduce an inconsistent style.

## Source files: don't introduce stray characters by accident

Don't let accidental non-ASCII creep into code or comments. The typical mistakes are
lookalike substitutions - em-dashes for `--`, curly quotes for `'`/`"`, arrows, non-breaking
spaces - and, worse, invisible characters like a NUL byte (`0x00`) or a zero-width space
landing inside a string literal. The invisible case is dangerous because reading the file back
does NOT catch it: it renders as nothing or as the character you meant. One reached a merge
request already (a NUL where a space was intended). Default to plain ASCII so these can't slip
in unnoticed.

This is about avoiding *accidents*, not banning non-ASCII. Deliberate, legitimate non-ASCII is
fine - an i18n/translation string, a file that already uses it, content that genuinely needs
it. Match the surrounding file. When a non-ASCII character is intentional but could look like a
mistake, prefer an escape (e.g. `é` for an accented letter) so it's visible in the source.

Run this check right after you write or edit a source file - not at commit time. I often do the
commit myself, so don't defer the check to a commit that may never be yours to make. Whenever
there's a real chance a stray or invisible character got in (string literals you typed,
copy-pasted text, anything you can't fully trust from reading it back), verify the bytes rather
than trusting your eyes:

```bash
python3 -c "d=open('FILE','rb').read(); print('NUL', d.count(b'\x00'), 'non-ASCII', sum(1 for b in d if b>127))"
```

Investigate any NUL, and any non-ASCII you didn't intend, as soon as the check flags it - right
after writing, not later.

## Working from a specification
- When the task involves something that has an official, well-defined specification - a file or
  message format like EDIFACT, Tradacoms, EANCOM, ISO 20022, X12, etc., or any formal
  standard - make sure you have actually READ the relevant part of the official spec document
  before implementing. Do not rely purely on memory or on what the existing code seems to do
  (memory can be wrong, and existing code may be buggy or incomplete).
- Cross-check against the spec repeatedly as you work - verify field definitions, segment
  order, cardinalities, allowed values, edge cases, etc. against the authoritative document,
  not against assumptions.
- If you don't have the spec (or the specific version) available, say so and ask me for it
  rather than guessing. When something in the code contradicts the spec, flag it.

## Code comments

**Before writing one**

- Prefer clearer code to a comment. If you are about to explain a block, first try extracting it into
  a well-named function. A comment is often an apology for code that could have spoken for itself.
- Every comment is a maintenance liability. Fewer, better ones beat thorough ones.

**What to write**

- Write for a reader who has only the code: no ticket, no specification, no chat history, no notes.
  If a comment only makes sense with one of those open, it is not doing its job.
- Capture what the types cannot express - units, ranges, invariants, ownership, thread-safety,
  nullability, what happens on failure. This is the highest-value comment there is.
- Document the surprising: workarounds, non-obvious ordering requirements, deliberate deviations from
  the approach a reader would expect. Anyone who might "fix" the code needs to know why it is like
  that.
- Justify every tolerance, guess and deviation, including its cost. When code accepts something
  non-conformant or infers a value, say what it accepts, why, and what is given up in exchange.
- Aim at the next decision, not the last one. The reader's question is almost always "may I change
  this?", so write what would break.
- Describe the current state of the code, not its history. Never explain how something used to be
  done or what changed ("previously…", "now we…", "renamed from…"), and don't write comments as if
  work is still in progress ("TODO: still need to…", "for now…", "temporary").

**Reasons versus references**

- Never let an external artefact be the reason. Citing a ticket, a review, a document or a person is
  an appeal to authority, not an explanation. State the durable fact: what is true about the data, the
  format or the domain that makes this code correct.
- When a standard justifies the code, state its rule, not its name. A reader can act on a rule; a
  document reference only tells them where to go looking.
- Then link freely. A ticket number, spec section or reference for a gnarly workaround is cheap and
  saves hours - as a supplement to the explanation, never as a substitute for it. Only link artefacts
  that live with the code; never point at working notes or scratch files (a `notes-local/` path is
  NEVER committed, so a comment referencing it is always a dangling reference).
- Apply the removal test. Delete every reference from the comment. If what remains is still true and
  still explains the code, the comment rests on the right thing. If it becomes meaningless, it does
  not.

**Where the comment belongs**

- Comment at the altitude of the code you are in. A comment belongs to its unit, not to the system.
- Separate the contract from the implementation. Interface and public documentation describe what
  callers can rely on; inline comments describe how it is achieved, for maintainers. Do not leak
  implementation detail into a contract.
- In a generic, abstract or shared type, describe only what any implementation must provide. Naming
  what one concrete implementation happens to do leaks detail upward, dates the comment as soon as a
  second implementation appears, and turns the abstraction into documentation of its first user. The
  same applies downward: a concrete class should not restate the contract its interface defines.

**Upkeep**

- A stale comment is worse than none, because people trust it. Change the comment in the same commit
  as the code it describes.

## Writing text deliverables (tickets, emails, message replies, summaries, drafts…)
- When I ask you to write any prose deliverable, ALWAYS write it to a file - never just
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
      `#NEW-mixed-vat`) and `Ref #NEW` in the draft - NEVER invent a number and NEVER use
      `#24466` for this. `#NEW` means "real ticket, number still unknown." Actively remind me
      each time that I haven't given you the ticket number yet. Once I tell you the real
      number, rename the folder and replace every `#NEW` (filenames + content) with it right
      away. `#NEW` must NEVER remain in content that goes into Redmine.
    - **Scratch/analysis that will never become a ticket:** use `#24466-<slug>` - locally
      `#24466` is the "no real ticket" marker. `#24466` must NEVER appear in real Redmine
      ticket content, and must NEVER be used as a placeholder for a ticket you're drafting
      (that's what `#NEW` is for).
  - Files *inside* that folder get plain, simple names - don't repeat the ticket number
    (e.g. `summary.md`, `assessment.md`, `logs/`).
- When I specify a tone, language style, or target audience (e.g. "easy to understand for
  someone new to the topic"), apply it silently. NEVER mention or explain the instruction in
  the generated text itself - just write to that brief.

## Ticket knowledgebase (mandatory)
- This whole section applies only to **real tickets**. `#24466` (the "no real ticket"
  marker) is EXCLUDED - don't auto-search for or auto-create a knowledgebase for it. A
  knowledgebase under `#24466-*` is only made if I explicitly ask.
- Whenever we work on a real ticket, you MUST keep a per-ticket knowledgebase as a Markdown
  file in `notes-local/`. Use the same layout as above:
  `notes-local/<release>/#<ticket>-<slug>/knowledgebase.md`.
- Create it as soon as we start on a ticket if it doesn't exist yet. From then on, keep it
  updated **on your own, without being asked** - refresh it along the way as you learn
  things, make decisions, or change the plan. Don't wait until the end.
- **NEVER ask me whether to update the knowledgebase.** The answer is always yes. You own the
  knowledgebase and are responsible for keeping it current - just update it, silently, as a
  matter of course. Asking is wrong; only the actual content going into Redmine ever needs my
  approval, never your working notes.
- This file is the key reference for starting NEW conversations on the same ticket. Write
  it so a future Claude with no memory of this session can get up to speed fast. It should
  work as an **index**: point to the relevant code (full paths + symbols), other
  `notes-local/` files, tickets/MRs, logs, and commands - so the next conversation knows
  where to go to gather information rather than rediscovering it.
- Good contents: the goal/ticket summary, current status, key findings, decisions made and
  why, open questions, what's been tried, next steps, and the pointers/index described
  above.
- This file is a working note and is **NEVER committed** (it lives in `notes-local/`, which
  is git-ignored). Because it won't be committed, it MAY freely reference other local files
  and paths - the "don't reference other files" rule for code comments does not apply here.
- When we start on a real ticket, fetch its current information from Redmine via the
  Redmine MCP on your own, without being asked (this is a read, which is always allowed;
  only Redmine *writes* need my approval). Use it to ground the knowledgebase and your
  understanding, and refresh it if the ticket may have changed since you last looked.
- Also actively download and read the ticket's attached files via the Redmine MCP (specs,
  sample messages, screenshots, logs, documents) - don't skip them or assume their contents.
  They often carry essential detail. Read the relevant ones to ground your understanding, and
  note in the knowledgebase which attachments exist and what they contain.
- It is YOUR responsibility to find an existing knowledgebase before starting work - don't
  wait for me to point you to it. As soon as a ticket comes up, search `notes-local/`
  across releases for a matching `#<ticket>-*` folder / `knowledgebase.md` (the ticket may
  be filed under a release folder you don't expect, so search broadly, not just one path).
  If you find one, read it before doing anything else. If you don't, create a fresh one.
- Watch for scope drift: if it becomes clear the ticket's actual scope has changed from what
  its Redmine description says (we're solving a different/bigger/smaller problem, the
  requirements shifted, etc.), actively raise it and ASK me whether I want to rewrite the
  ticket description. Don't silently work around the mismatch. NEVER update the Redmine ticket
  yourself - only I decide whether and how to change it (this is a Redmine write, which always
  needs my explicit approval). You may draft a proposed new description locally for me to
  review if I ask.
