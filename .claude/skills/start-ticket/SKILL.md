---
name: start-ticket
description: Start working on an existing Redmine ticket - fetch the ticket and related tickets, download all attachments, create a feature branch, and build the knowledgebase. Use when the user wants to begin work on a ticket ("start ticket 44625", "let's work on #43134").
---

# Start work on a Redmine ticket

Bootstrap everything needed to begin work on an existing ticket: read it, read the related
tickets, download its attachments, set up a feature branch, and create the per-ticket
knowledgebase. This follows the global "Ticket knowledgebase" rules - it is the entry point
that performs them as one flow.

## Nothing happens without a ticket number

Do NOTHING until you know the ticket number. If the user didn't give one, ASK for it and stop
there. No branch, no folder, no fetch - the ticket number is required first. (The `#24466`
no-real-ticket marker is not a real ticket; if that's all there is, this skill does not apply.)

## Steps (in order)

1. **Read the ticket.** Fetch it from Redmine via the Redmine MCP (`get_issue`, read-only, no
   approval needed). Capture: subject, description, status, assignee, priority, and the
   Zielversion / target release (the MCP omits it - use the raw REST API, see the
   `redmine-zielversion-lookup` memory). The release names the knowledgebase folder.

2. **Read the related tickets.** For tickets this one links to or references (parent, blocked-by,
   related, or numbers mentioned in the description), fetch and read them too for context. Read
   the relevant ones; don't just collect numbers. Reference other tickets sparingly in your own
   notes - once each, not repeated.

3. **Download ALL attachments.** Pull every attachment via the Redmine MCP (specs, sample
   messages, screenshots, logs, documents) into the ticket folder under an `attachments/`
   subdir. Do not skip any or assume their contents - actually read the relevant ones and note
   in the knowledgebase what each contains.

4. **Confirm the repo and base, then create a feature branch.** Creating a branch is a git
   action that needs my explicit OK (global git rules) - so:
   - Confirm which repo we're working in. Always branch off the up-to-date `origin/master`
     (`git fetch` first so it isn't stale), even for hotfix-related tickets - hotfix releases
     are made by hand by cherry-picking the relevant commits, so the feature branch still starts
     from `origin/master`. Only branch off something else if I explicitly say so. If a server is
     unreachable, it's probably the VPN - stop and tell me.
   - Look at the repo's existing branch naming (`git branch -a`) and propose a branch name that
     matches that convention, tied to this ticket (e.g. `<user>/<ticket>_<slug>`).
   - Show me the exact command (`git fetch` then
     `git checkout -b <name> --no-track origin/master`) and ASK before running it. Use
     `--no-track`: branching off a remote-tracking branch would otherwise set the new branch's
     upstream to `origin/master`, which makes tools (e.g. IntelliJ) default the push target to
     master - risking an accidental push of feature commits to master. `--no-track` leaves the
     branch with no upstream, so the first push creates a new `origin/<name>` instead. Do not
     create, switch, or push the branch until I approve. Never push.

5. **Create the knowledgebase.** Create `knowledgebase.md` in the ticket folder (see *Output*),
   grounded in everything above. From here on keep it updated on your own per the global rules.
   If a knowledgebase already exists for this ticket, read it first and update rather than
   overwrite.

## Output

- Ticket folder: `<repo-root>/notes-local/<release>/#<ticket>-<slug>/` (per the global
  notes-local layout). If you can't determine the release, look it up via the Zielversion
  lookup or ask me. `<slug>` is 2-4 words.
- Attachments go in `<ticket folder>/attachments/`.
- The knowledgebase file is `knowledgebase.md` in that folder. Good contents: goal/summary,
  current status, key findings, decisions and why, open questions, next steps, and an index
  pointing at the relevant code (full paths + symbols), the attachments, related tickets/MRs,
  logs, and commands - so a future conversation knows where to look.
- `notes-local/` is never committed, so the knowledgebase may freely reference local paths.

## Boundaries

- Redmine reads are always fine; never do a Redmine write here (this skill only reads).
- Branch creation needs explicit per-action approval every time; a previous OK never carries
  over. Never push branches or tags.
