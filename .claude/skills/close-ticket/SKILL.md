---
name: close-ticket
description: Draft a Redmine closing comment that summarizes the final solution for a ticket — how a bug was fixed / a feature was built, plus any follow-ups left undone. Use when the user wants to close a ticket, write a solution summary, or add a final comment. Output is Markdown (Redmine is configured for Markdown), in English, in easy-to-understand language.
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
- The ticket itself - ALWAYS re-read it fresh from Redmine (`get_issue`, read-only) at the start,
  even if you think you already know it. It may have changed (new comments, status, requirements)
  since you last looked, and the closing comment must reflect the current state. Refresh the
  knowledgebase from this too. To place the file in the right release folder, look up the ticket's
  Zielversion (the MCP omits it - use the raw REST API, see the `redmine-zielversion-lookup`
  memory).

If you lack a fact needed for a section (e.g. the root cause), ask the user (one question at a
time) rather than inventing it.

## First: is the ticket actually solved?

Before writing any closing comment, evaluate whether the ticket is really done. Do NOT jump
straight to the draft.

1. List everything the ticket requires - each requirement, acceptance criterion, or task the
   ticket calls for - as a checklist, one item per line.
2. Mark each item with an emoji status: ✅ for done, ❌ for not done yet (use ⚠️ for partially
   done / uncertain, and say why). Base this on the conversation, git context, and the ticket
   itself, not on optimism.
3. Show me this checklist so the state is obvious at a glance.
4. Then ASK me whether to generate the closing comment. Do not write it unless I say yes - if
   items are still open (❌), point that out and let me decide whether to close anyway.

Example:

```
Ticket completion:
✅ Split-invoice rounding fixed
✅ Regression test added
❌ Documentation updated
```

Only after I confirm do you move on to writing the closing comment below.

## Rules (non-negotiable)

- **Format:** Markdown only (Redmine is configured for Markdown). Use `####`/`#####` headings,
  `---` horizontal rules, `**bold**`, `*italics*`, `` `inline code` ``, `-` bullets, and fenced
  `` ``` `` code blocks. Never Textile (`h4.`, `@code@`, `<pre>` render wrong in Redmine now).
- **Language:** Always write in **English**, even if the user describes it in another language.
- **Short and to the point - no AI slop:** The whole comment should fit on one screen. Prefer
  short bullets and fragments over sentences; one line per point. Keep each section to roughly
  1-3 lines. Explain the "why" in as few words as it takes. Cut all filler ("in order to", "it
  is worth noting", "this ensures that", "as mentioned"), do not restate the ticket, no praise,
  no meta-commentary. Someone who didn't do the work should still understand it - clarity through
  brevity, not volume.
- **Be honest about what's left:** Always state follow-ups / not-done / known limitations.
- **Always offer follow-up tickets:** After writing the closing comment, ALWAYS offer to draft a
  Redmine ticket (via the `ticket` skill) for each follow-up task / open issue you listed in
  *Follow-Ups / Not Done* — even if the user didn't ask. List the concrete follow-ups you'd
  create and let the user pick which ones (or none). See *Offer follow-up tickets* below.
- **Fill, don't leave placeholders:** Replace every `_italic placeholder_` with real content.
  Drop a section only when it genuinely doesn't apply (e.g. *Root Cause* for a pure feature) -
  don't leave an empty heading.
- **Never self-reference the ticket:** The comment lives on the ticket, so don't link or
  mention the ticket's own number in it (a comment on `#44625` must not contain `#44625` or a
  link to it). Reference OTHER tickets when relevant, never the current one.
- **Offer to upload referenced files:** If the closing comment refers to a specific file (a test
  file, sample message, log, screenshot, export, etc.), list each one once after the draft with
  its **full absolute path**, and OFFER to upload it to the Redmine ticket for me. Let me pick
  which to upload (or none). Redmine renders no file from a path alone - it must be attached.
  Uploading uses the raw REST API (the Redmine MCP has no upload tool) - see the
  `redmine-attach-file-via-rest` memory for the exact two-step flow and safety procedure. Each
  upload is a Redmine WRITE and needs its own fresh explicit approval every time (uploading the
  bytes is safe; attaching to the issue is the write). Follow the memory's safety steps: snapshot
  the issue first, put ONLY `uploads` in the PUT body, diff after, verify the sha. Pick the file
  by reading the ticket, not guessing from its number; never print the API key. Real supplier
  files carry real account/invoice numbers - attaching one publishes them to everyone who can
  read the ticket, so say so explicitly before uploading.
- **Update the knowledgebase:** After drafting the closing comment, update the ticket's
  `knowledgebase.md` (see the global "Ticket knowledgebase" rules) so it reflects the final
  state - solution, what changed, completion status, and any follow-ups left. It should be
  accurate for a future conversation that reopens this ticket. Skip only for the `#24466`
  no-real-ticket marker, which has no knowledgebase.

## Template

Keep it lean. One line per point. Drop any section that doesn't apply (don't leave an empty
heading). Example of the target length:

```
#### Solution
Cent rounding on split invoices fixed.

#### Root Cause
Rounded per-line, not per-invoice. `a1b2c3d`

#### Changed
- Round total once (`InvoiceCalc`) `a1b2c3d`
- Regression test `e4f5g6h`

#### Follow-Ups
- None
```

Section guide (all terse):

- **Solution** - one line: what resolved the ticket.
- **Root Cause** - bugs only, one line: the underlying cause. Omit for features/tasks.
- **Changed** - bullets: what changed and where (component/file), each with its commit/PR/branch
  ref. No prose paragraphs.
- **Follow-Ups** - bullets of what's left out on purpose / known limits, or `- None`.
- **How To Verify** - optional; include only if useful, as short bullets.

## Output

Follow the global "Writing text deliverables" rules:

1. Write the comment to a file with the **`.md`** extension — never just print it in chat.
2. Location: `<repo-root>/notes-local/<release>/#<ticket>-<slug>/closing-comment.md`, e.g.
   `notes-local/release 3.19/#43992-observability/closing-comment.md`. Place it in the
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
