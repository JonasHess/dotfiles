---
name: ticket
description: Draft a Redmine ticket (feature, bug, or task) from a short description. Use when the user wants to create a Redmine ticket or write a ticket draft. Writes the ticket in Markdown format (Redmine is configured for Markdown), in English, in easy-to-understand language.
---

# Create a Redmine ticket

Turn the user's description into a well-structured Redmine ticket draft.

**"Create a ticket" means write a file.** When the user asks to create a ticket, they want
Claude to write a ticket draft to a file (see *Output* below) — **not** to connect to the
Redmine API or create anything in Redmine. Only push to Redmine after explicit approval (see
*Pushing to Redmine*).

**A newly drafted ticket has NO number yet.** When you draft a new ticket, its real Redmine
number is unknown until the user gives it to you. Use `#NEW` as the placeholder — `Ref #NEW`
in the content and `#NEW-<slug>/` for the folder. NEVER invent a number, and NEVER use
`#24466` for a ticket you're drafting. Actively remind the user, each time, that you don't
know the ticket number yet. As soon as the user provides the real number, rename the folder
and replace every `#NEW` (filename + content) with it; `#NEW` must never remain in anything
that goes to Redmine.

**Ticket #24466 is an internal convention** meaning "I was too lazy to create a ticket" — for
scratch/analysis that will never become a real ticket. It is not a real ticket and is NOT a
placeholder for a ticket you're drafting (that's `#NEW`). Never mention, reference, or include
#24466 in the **ticket content** you write (the Markdown body that may go to Redmine). It *is*
allowed locally as the "no real ticket" marker in a `notes-local/` folder name
(`#24466-<slug>/`) for non-ticket scratch work — see *Output*.

## Rules (non-negotiable)

- **Format:** Markdown only (Redmine is configured for Markdown). Use `####`/`#####` headings,
  `---` horizontal rules, `**bold**`, `*italics*`, and `-` bullets. Never Textile
  (`h4.`, `@code@`, `*bold*` Textile-style render wrong in Redmine now).
- **Language:** Always write the ticket in **English**, even if the user describes it in
  another language.
- **Reading level:** Use **simple, easy-to-understand language**. Short sentences. Avoid
  jargon where a plain word works. A non-expert should grasp the ticket.
- **Always include the title:** Every ticket draft MUST start with the recommended ticket
  **title** (the Redmine *Subject*), clearly labelled so it's obvious it goes in the Subject
  field, not the description body. Never write only the description — the title is required.
- **Technical tickets:** If the ticket is technical (developer-facing, internal engineering
  work — infrastructure, refactor, API, data migration, etc.), prefix the **title** with
  `[TT] `. Non-technical / business tickets get no prefix.
- **Fill, don't leave placeholders:** Replace every `_italic placeholder_` with real content
  based on what the user told you. If you genuinely lack the information for a section, ask the
  user (one question at a time) rather than inventing facts. Drop sections only when the
  template says they are optional and the user has nothing to add (e.g. *Testing Scenarios*).
- **Problem first (bugs & tasks):** For **bug** and **task** tickets, keep the *problem* in the
  foreground — describe what is wrong or what is needed and why it matters (the impact), not how
  to fix it. You MAY suggest a possible solution, but clearly mark it as a suggestion and state
  that the final decision on how to solve it is left to whoever picks up the ticket. Never write
  the ticket as if a particular implementation is already decided. (Features may describe the
  expected behaviour in more detail, since that defines the feature.)

## Picking the template

Ask the user which type if it is not obvious from their description:

- **Feature** — new capability or enhancement.
- **Bug** — something is broken / behaves wrong. Push for more reproduction detail in
  AS-IS-STATE (concrete examples, links, mailboxes, steps).
- **Task** — a unit of work that is neither a new feature nor a defect (chore, setup, follow-up).

All three share the same section structure below. The only practical difference is emphasis:
bugs need strong reproduction detail in AS-IS-STATE.

## Template

```
**Title (Redmine Subject):** <recommended ticket title — prefix with `[TT] ` if technical>

---

#### User Story / Description

As a user I ...

---

#### AS-IS-STATE

_describe the current situation as best as possible, including any examples, links and mailboxes if available._
_(bugs: give as much specific detail as possible so the issue can be reproduced.)_

---

#### TO-BE-STATE

_describe the expected outcome — the problem solved / what is needed. for bugs and tasks, state the desired result, not a prescribed implementation. if there are official specifications (e.g. a trading format like Tradacoms), quote the specific section and ideally add a link to those specifications._

##### Possible Solution (suggestion only)

_optional, bugs & tasks: a suggested approach if you have one. Make clear this is only a suggestion — the person working the ticket decides how to actually solve it. Omit if you have no suggestion._

##### Acceptance Criteria

_define the conditions that must be met for this ticket to be considered complete and accepted._

---

#### Priority

_low, medium, or high_

---

#### Customer Impact

_short summary of the customer impact. Can be reused for Release Notes._

---

#### Actors

_internal or external. if external, note retailer- or supplier-based, and if it is a specific customer rather than a group, the customer name._

---

#### Testing Scenarios

_optional — only fill in if you want to specify testing instructions._
```

## Output

Follow the global "Writing text deliverables" rules:

1. Write the ticket to a file with the **`.md`** extension — never just print it in chat.
2. Location: `<repo-root>/notes-local/<release>/#<ticket>-<slug>/`, e.g.
   `notes-local/release 3.18/#43134-mixed-vat/ticket.md`. If you don't know the release,
   ask the user before creating the folder. Since a freshly drafted ticket has no number yet,
   use `#NEW-<slug>` (e.g. `#NEW-mixed-vat/`) and remind the user you don't know the number;
   rename the folder once they give you the real number. (`#24466-<slug>` is only for
   scratch work that will never become a ticket — not for a ticket you're drafting.) The file
   inside gets a plain name like `ticket.md` — don't repeat the ticket number in the filename.
3. After writing, open it for the user: `idea -e <path>`.

## Pushing to Redmine

Do **not** create or update anything in Redmine on your own. Redmine is production: every
write must be shown to the user and explicitly approved first. Produce the draft file, then
ask whether to create the ticket in Redmine — and if approved, use the Redmine MCP tools.
