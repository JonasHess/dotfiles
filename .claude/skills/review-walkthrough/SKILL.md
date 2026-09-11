---
name: review-walkthrough
description: In-depth review of a GitLab merge request that ends in an interactive, one-finding-at-a-time walkthrough. Given a ticket number or MR URL, safely switch to the MR branch, read the ticket and MR, review the code (test locally where possible), write findings to a Markdown file, then walk through each finding one by one - each with a ready-to-paste German MR comment and the exact file:line to attach it to. Use when the user wants to review an MR and get attachable review comments.
---

# MR review with an interactive walkthrough

Given a ticket number or GitLab MR URL, do a thorough code review and then walk me through the
findings one at a time, each with a short German comment I can paste onto the MR at a specific
file and line.

## Nothing happens without the ticket/MR

Do nothing until I give a ticket number or MR URL. If it's missing, ASK and stop. If GitLab is
unreachable (timeout, DNS, connection refused), it's probably the VPN - stop and tell me, don't
work around it.

## Steps (in order)

1. **Resolve the MR.** From the ticket number or URL, find the MR: its title, source and target
   branch, author, and the ticket(s) it relates to. Always refer to the MR by its title and the
   tickets/branches it touches, not by its bare ID.

2. **Switch to the MR branch - safely.** Checking out a branch is a git action that needs my
   explicit OK (global git rules):
   - First make sure NO uncommitted work is lost: run `git status`; if the working tree is dirty,
     STOP and warn me, and don't switch until I say how to handle it (stash, commit, or discard is
     my call).
   - `git fetch` so we're not on a stale view.
   - Show me the exact `git checkout` command for the MR's source branch and ASK before running
     it. Never push.

3. **Read the ticket and the MR.** Fetch the ticket(s) from Redmine via the Redmine MCP
   (read-only) and download + read their attachments. Read the full MR (description + diff).

4. **Understand intent vs. change.** Before judging anything, be clear on TWO things: what the
   ticket is actually asking for, and what the code actually changed. The core review question is
   whether the second delivers the first.

5. **Review in depth, and verify locally where possible.** Read the diff and enough surrounding
   code to judge it - not just the changed lines. Prefer to actually test/verify the change
   locally. If running or verifying it needs applications started locally, ASK me for assistance
   (I start local apps - don't launch them yourself). Cover at least: correctness, edge cases,
   does it match the ticket, fit with existing patterns, tests, security/data, readability.

6. **Write the findings file.** Produce the review as a Markdown file (see *Output*) before the
   walkthrough, so there's a written record.

7. **Walk me through the findings - ONE AT A TIME.** After the file is written, present the
   findings interactively: show ONE finding, then wait. I will say **"next"** to move to the next
   one. Never dump several findings at once. Most important first. For each finding show:
   - a short plain-language explanation of the issue and why it matters,
   - the exact **file and line** to attach a comment to,
   - a short, plain-language **German** comment I can paste directly onto the MR at that line.

## The German MR comments

- Written in **German**, short and plain - the tone of a normal, friendly review comment a
  colleague would leave, not a formal report. One clear point per comment.
- Ready to paste as-is: no "Suggestion:" labels, no meta, just the comment.
- Always paired with the `file:line` it belongs on, so I know where to attach it.

## Output

- Plain, easy-to-understand language in the file (the findings/explanations may be in English; the
  paste-ready MR comments are German as above).
- Write to `<repo-root>/notes-local/<release>/#<ticket>-<slug>/code-review.md` (global notes-local
  layout; no whitespace in paths). If you can't determine the release, look it up via the
  Zielversion lookup or ask me.
- Suggested structure: a one-line summary + overall verdict at the top, then the findings ordered
  by severity, each with: `file:line`, the issue + why (plain language), and the German paste-ready
  comment.
- Keep the per-ticket knowledgebase updated from what you learn (global rules).

## Boundaries

- Redmine and GitLab reads are fine. Never do a Redmine write here.
- Branch checkout needs explicit per-action approval every time; a previous OK never carries over.
  Never push branches or tags. This skill reviews and reports; it does not change the MR's code.
