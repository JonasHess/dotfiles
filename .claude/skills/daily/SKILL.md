---
name: daily
description: Generate talking points for my daily standup from my recent git commits. Looks at my commits from the last 1-2 days, groups them by ticket, and lists in bullet points what was done - ticket number and ticket headline first. Use when the user wants daily/standup notes ("what do I say in daily", "/daily").
---

# Daily standup notes

Turn my recent commits into a short list of things I can say in the daily meeting. Focus on
what was done, grouped by ticket, with the ticket number and headline up front.

## Steps

1. **Find my recent commits.** In the current repo, list commits I authored in the last 1-2 days:

   ```bash
   git log --since="2 days ago" --author="$(git config user.email)" --pretty=format:'%h %s'
   ```

   If nothing shows, widen to `3 days ago` (covers a weekend) before concluding there's nothing.
   If I mention other repos (or say "all"), repeat this in each - my repos live under
   `~/repos/<name>` or `~/IdeaProjects/<name>`. When unsure which repos to include, ask me once.

2. **Group by ticket.** Extract the ticket number from each commit subject (`Ref #<num>` in
   pubx/mvb repos). Group all commits for the same ticket together. Commits with no ticket
   (dotfiles, etc.) group under their repo/scope.

3. **Get the ticket headline.** For each ticket number, fetch its subject from Redmine via the
   Redmine MCP (`get_issue`, read-only). The ticket number AND its headline are the most
   important part of each bullet - lead with them.

4. **Summarize what was done.** For each ticket, condense its commits into 1-2 short plain-language
   bullets of what actually got done (not a raw commit list). Keep it to what I'd actually say out
   loud in a standup.

## Output

Write to a file (per the global "Writing text deliverables" rules), then open it with
`idea -e <path>`.

- Location: `<repo-root>/notes-local/daily/<YYYY-MM-DD>-standup.md` (today's date as prefix).
- Plain, easy language. Short bullets. No filler, no wall of text.
- Format:

  ```
  # Daily standup - <YYYY-MM-DD>

  ## Done (last 2 days)
  - #43134 mixed VAT rounding: fixed cent rounding on split invoices, added regression test
  - #44625 <ticket headline>: <what was done>
  - dotfiles (no ticket): added start-ticket and review-mr skills
  ```

- Lead each bullet with `#<ticket> <headline>`, then a colon and what was done. Tickets first,
  no-ticket work last. If a ticket number has no reachable headline (Redmine down / VPN), say so
  and keep the number.
