---
name: review-mr
description: Full in-depth review of a GitLab merge request, ending in an interactive one-finding-at-a-time walkthrough. Given a ticket number or MR URL, safely switch to the MR branch (without losing uncommitted work), read the ticket and attachments and the code changes, build the knowledgebase, review in depth (test locally where possible), write findings to a Markdown file, then walk through each finding one by one - each with the exact file:line and a ready-to-paste German MR comment. Use when the user gives a GitLab MR or ticket to review.
---

# Review a GitLab merge request

Given a ticket number or GitLab MR URL, set up the branch and context, do a thorough review,
write the findings to a Markdown file, then walk me through them one at a time - each with a
short German comment I can paste onto the MR at a specific file and line.

## Nothing happens without the ticket/MR

Do nothing until I give a ticket number or MR (URL or ID). If it's missing, ASK and stop. If
GitLab is unreachable (timeout, DNS, connection refused), it's probably the VPN - stop and tell
me, don't work around it.

## Steps (in order)

1. **Identify the MR.** Resolve its title, source and target branch, author, and the ticket(s) it
   references. Always refer to the MR by its **title and the tickets/branches it touches**, not by
   its bare ID (the ID is mostly irrelevant).

2. **Switch to the MR branch - safely.** Checking out a branch is a git action that needs my
   explicit OK (global git rules):
   - First make sure NO uncommitted work is lost: run `git status`; if the working tree is dirty,
     STOP and warn me, and don't switch until I say how to handle it (stash, commit, or discard is
     my call).
   - `git fetch` so we're not on a stale view.
   - Show me the exact `git checkout` command for the MR's source branch and ASK before running
     it. Don't switch until I approve. Never push.

3. **Read the ticket + attachments.** For the ticket(s) the MR references, fetch them from Redmine
   via the Redmine MCP (read-only) and download ALL their attachments into the ticket folder's
   `attachments/`. Read the relevant ones - don't assume their contents. (Same context-gathering
   as the `start-ticket` skill.)

4. **Understand intent vs. change.** Be clear on TWO things before judging: what the ticket is
   actually asking for, and what the code actually changed. The core question is whether the change
   delivers what the ticket asked. Read the full MR diff and enough surrounding code to understand
   it, not just the changed lines.

5. **Review in depth, and verify locally where possible.** Prefer to actually test/verify the
   change locally. If running or verifying it needs applications started locally, ASK me for
   assistance (I start local apps - don't launch them yourself). You MAY use the built-in
   `/code-review` on the diff as one input, but this review is deeper (see *The review itself*).

6. **Create the knowledgebase.** Create/update `knowledgebase.md` in the ticket folder (global
   "Ticket knowledgebase" rules) so a future conversation can pick this up - what the MR does, the
   branch, key findings, and an index into the code, attachments, and related tickets.

7. **Write the findings file** (see *Output*) - before the walkthrough, so there's a written
   record.

8. **Walk me through the findings - ONE AT A TIME.** After the file is written, present the
   findings interactively: show ONE finding, then wait. I say **"next"** to move to the next one.
   Never dump several at once. Most important first. For each finding show:
   - a short plain-language explanation of the issue and why it matters,
   - the exact **file and line** to attach a comment to,
   - a short, plain-language **German** comment I can paste directly onto the MR at that line.

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

## The German MR comments

- Written in **German**, short and plain - the tone of a normal, friendly review comment a
  colleague would leave, not a formal report. One clear point per comment.
- Ready to paste as-is: no "Suggestion:"/"Vorschlag:" labels, no meta, just the comment.
- Always paired with the `file:line` it belongs on, so I know where to attach it.

## Output

- Plain, easy-to-understand language. Short sentences. Explain the "why". Someone who didn't write
  the code should follow it. No filler, no padding. (Findings/explanations may be English; the
  paste-ready MR comments are German as above.)
- Write to `<repo-root>/notes-local/<release>/#<ticket>-<slug>/review.md` (global notes-local
  layout; no whitespace in paths). If you can't determine the release, look it up via the
  Zielversion lookup or ask me.
- Structure: a one-line summary + overall verdict at the top, then findings grouped by severity
  (blocking / should-fix / nits), each with `file:line`, the problem, why, the fix, and the German
  paste-ready comment.
- After writing, open it for me: `idea -e <path>`.

## Boundaries

- Redmine and GitLab reads are fine. Never do a Redmine write here.
- Branch checkout needs explicit per-action approval every time; a previous OK never carries over.
  Never push branches or tags.
- This skill reviews and reports; it does not change the MR's code.
