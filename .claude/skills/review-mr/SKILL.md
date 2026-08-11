---
name: review-mr
description: Do a full in-depth review of a GitLab merge request. Switch to the MR branch, read the ticket and its attachments, read the code changes, build a knowledgebase, then write the review findings to a Markdown file in plain easy-to-understand language. Use when the user gives a GitLab MR to review.
---

# Review a GitLab merge request

Given a GitLab MR (URL or ID), set up the branch and context, then do a thorough review and
write the findings to a Markdown file in plain, easy language.

## Nothing happens without the MR

Do nothing until you have the MR (URL or ID). If it's missing, ASK for it and stop. If GitLab is
unreachable (timeout, DNS, connection refused), it's probably the VPN - stop and tell me, don't
work around it.

## Steps (in order)

1. **Identify the MR.** Resolve its title, source and target branch, author, and the ticket(s) it
   references. Always refer to the MR by its **title and the tickets/branches it touches**, not
   by its bare ID (the ID is mostly irrelevant).

2. **Switch to the MR branch.** Checking out a branch is a git action that needs my explicit OK
   (global git rules):
   - Confirm the repo, then `git fetch` so we're not on a stale view.
   - Warn me if the working tree is dirty (a checkout could lose work) before doing anything.
   - Show me the exact `git checkout` command for the MR's source branch and ASK before running
     it. Don't switch until I approve. Never push.

3. **Read the ticket + attachments.** For the ticket(s) the MR references, fetch them from
   Redmine via the Redmine MCP (read-only) and download ALL their attachments into the ticket
   folder's `attachments/`. Read the relevant ones - don't assume their contents. (This is the
   same context-gathering as the `start-ticket` skill.)

4. **Read the code changes.** Read the full MR diff and enough surrounding code to understand it
   - not just the changed lines. Understand what the change is trying to do and how it fits the
   existing code. You MAY use the built-in `/code-review` on the diff as one input, but this
   review is deeper: correctness, edge cases, matching the ticket's intent, fit with existing
   patterns, tests, and anything the diff-only pass would miss.

5. **Create the knowledgebase.** Create/update `knowledgebase.md` in the ticket folder (global
   "Ticket knowledgebase" rules) so a future conversation can pick this up - what the MR does,
   the branch, key findings, and an index into the code, attachments, and related tickets.

6. **Write the review findings.** Produce the review as a Markdown file (see *Output*).

## The review itself

Be thorough and specific. Cover at least:

- **Correctness** - bugs, wrong logic, unhandled edge cases, off-by-one, null/empty, error paths.
- **Does it match the ticket?** - does the change actually solve what the ticket asked, including
  any official spec it must follow (read the spec, don't trust memory).
- **Fit with the codebase** - follows existing patterns (logging, naming, structure, error
  handling, existing helpers) rather than a new inconsistent style.
- **Tests** - are the changes covered, do the tests actually assert the behaviour.
- **Security / data** - injection, secrets in code, leaking real customer/supplier data.
- **Readability / maintainability** - clarity, dead code, comments that earn their place.

For each finding: where it is (`file:line`), what's wrong, why it matters, and a concrete
suggestion. Rank most important first. Separate real problems from minor nits. If something is
good or deliberately fine, it's OK to say so briefly - don't invent problems to pad the list.

## Output

- Plain, easy-to-understand language. Short sentences. Explain the "why". Someone who didn't write
  the code should follow it. No filler, no padding.
- Write to `<repo-root>/notes-local/<release>/#<ticket>-<slug>/review.md` (global notes-local
  layout). If you can't determine the release, look it up via the Zielversion lookup or ask me.
- Suggested structure: a one-line summary + overall verdict at the top, then findings grouped by
  severity (blocking / should-fix / nits), each with `file:line`, the problem, why, and the fix.
- After writing, open it for me: `idea -e <path>`.

## Boundaries

- Redmine and GitLab reads are fine. Never do a Redmine write here.
- Branch checkout needs explicit per-action approval every time; a previous OK never carries over.
  Never push branches or tags.
- This skill reviews and reports; it does not change the MR's code.
