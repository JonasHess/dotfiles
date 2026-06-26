---
name: close-ticket
description: Draft a Redmine closing comment that summarizes the final solution for a ticket — how a bug was fixed / a feature was built, plus any follow-ups left undone. Use when the user wants to close a ticket, write a solution summary, or add a final comment. Output is Redmine textile, in English, in easy-to-understand language.
---

# Write a Redmine closing comment

Turn the work that was done into a clear closing comment for a Redmine ticket — the kind you
paste into the ticket as a final note before resolving/closing it. It explains the final
solution (how the bug was fixed or the feature was built) and lists any follow-up work that was
deliberately left out.

**"Close a ticket" / "write the solution" means write a file.** The user wants Claude to write a
closing-comment draft to a file (see *Output*) — **not** to add a note or change status in
Redmine. Only push to Redmine after explicit approval (see *Pushing to Redmine*).

## Gather the facts first

Base the comment on what actually happened, not guesses. Pull from:

- The current conversation (what was diagnosed and changed).
- Git context when relevant: recent commits, the branch diff, PR description
  (e.g. `git log --oneline`, `git diff`). Reference concrete commits / PRs / branches.
- The ticket itself — if a ticket number is known, you may read it for context with the Redmine
  MCP `get_issue` (read-only is fine). To place the file in the right release folder, look up the
  ticket's Zielversion (the MCP omits it — use the raw REST API, see the
  `redmine-zielversion-lookup` memory).

If you lack a fact needed for a section (e.g. the root cause), ask the user (one question at a
time) rather than inventing it.

## Rules (non-negotiable)

- **Format:** Redmine wiki / textile markup only. Use `h4.`/`h5.` headings, `---`/`----`
  horizontal rules, `_italics_`, `@inline code@`, and `<pre>`/`</pre>` for code blocks. Never
  Markdown (`#`, `**`, `` ``` ``, `-` bullets render wrong in Redmine).
- **Language:** Always write in **English**, even if the user describes it in another language.
- **Reading level:** Use **simple, easy-to-understand language**. Short sentences. Explain the
  "why", not just the "what". Someone who didn't do the work should understand it.
- **Be honest about what's left:** Always state follow-ups / not-done / known limitations.
- **Always offer follow-up tickets:** After writing the closing comment, ALWAYS offer to draft a
  Redmine ticket (via the `ticket` skill) for each follow-up task / open issue you listed in
  *Follow-Ups / Not Done* — even if the user didn't ask. List the concrete follow-ups you'd
  create and let the user pick which ones (or none). See *Offer follow-up tickets* below.
- **Fill, don't leave placeholders:** Replace every `_italic placeholder_` with real content.
  Drop a section only when it genuinely doesn't apply (e.g. *Root Cause* for a pure feature) —
  don't leave an empty heading.

## Template

```
h4. Solution

_one or two sentences: what was done to resolve this ticket._

---

h4. Root Cause

_for bugs: why it actually happened — the underlying cause, not just the symptom. Omit this section for pure features/tasks._

---

h4. What Was Changed

_explain the fix / implementation in plain language: what changed and where (which component / repo / file), and why that resolves the issue. Quote the relevant commits / PRs / branches._

---

h4. Follow-Ups / Not Done

_anything left out of scope on purpose, known limitations, or follow-up work that should become its own ticket. Write "None." if everything is finished._

---

h4. How To Verify

_steps to confirm it works: what was tested, in which environment, and the expected result. Optional but recommended._
```

## Output

Follow the global "Writing text deliverables" rules:

1. Write the comment to a file with the **`.textile`** extension — never just print it in chat.
2. Location: `<repo-root>/notes-local/<release>/#<ticket>-<slug>/closing-comment.textile`, e.g.
   `notes-local/release 3.19/#43992-observability/closing-comment.textile`. Place it in the
   ticket's existing folder if one exists. If you don't know the release, look it up via the
   Zielversion lookup, or ask the user. When there is no real ticket number, use
   `#24466-<slug>` (the local "no real ticket" marker). The file gets a plain name — don't
   repeat the ticket number in the filename.
3. After writing, open it for the user: `idea -e <path>`.

## Offer follow-up tickets

This is mandatory, every time — not optional. Right after producing the closing comment:

- Look at what you put under *Follow-Ups / Not Done* (plus any open issues raised during the
  work). For each one, briefly state the follow-up you could turn into a ticket.
- **Always ask the user whether to draft tickets for them**, e.g. "I noted 2 follow-ups — want
  me to draft `/ticket`s for them?". List them so the user can choose which to create (or none).
- For each one the user accepts, invoke the `ticket` skill to draft it (same release folder /
  conventions). If there are no follow-ups (*Follow-Ups / Not Done* is "None."), say so and skip.

## Pushing to Redmine

Do **not** add the note or change the ticket status on your own. Redmine is production: every
write must be shown to the user and explicitly approved first. Produce the draft file, then ask
whether to post it — and if approved, add it as a note with the Redmine MCP (`add_issue_note`),
and only change status (resolve/close) if the user explicitly asks.
