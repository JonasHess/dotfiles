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

- **Lean, no AI slop:** The whole ticket should fit on one screen. Short sentences and bullets,
  one point per line. Cut filler ("this ticket aims to", "in order to", "it is worth noting"),
  never restate the title, no meta-commentary, no padding. Teammates read these and complain
  when they are long and bloated - keep it tight.
- **Say each fact once:** Do not repeat the same information across sections. If the user story
  already carries the role and the value, don't restate them in *Actors* or *Customer Impact*.
  Repetition is what reads as slop.
- **Omit redundant or empty sections:** Include a section only when it adds concrete new info.
  A thin or restating section is worse than no section - drop it. Only *Description*, *AS-IS*
  (bugs), *TO-BE / Acceptance Criteria*, and *Priority* are always present; the rest are
  optional (see the template).
- **Normal professional English:** Write the ticket content in plain, clear English (NOT the
  caveman chat style) - teammates read it. Terse and lean, but full words and readable.
- **Format:** Markdown only (Redmine is configured for Markdown). Use `####`/`#####` headings,
  `---` horizontal rules, `**bold**`, `*italics*`, and `-` bullets. Never Textile
  (`h4.`, `@code@`, `*bold*` Textile-style render wrong in Redmine now).
- **Language:** Always write the ticket in **English**, even if the user describes it in
  another language.
- **Always include the title:** Every ticket draft MUST start with the recommended ticket
  **title** (the Redmine *Subject*), clearly labelled so it's obvious it goes in the Subject
  field, not the description body. Never write only the description — the title is required.
- **Technical tickets — ALWAYS ask, never decide yourself:** Ask me whether this is a technical
  ticket (developer-facing, internal engineering work — infrastructure, refactor, API, data
  migration, etc.) or not. You may say which you'd guess, but you must ask and let me confirm.
  If I say technical, prefix the **title** with `[TT] `; non-technical / business tickets get no
  prefix.
- **Fill, don't leave placeholders:** Replace every `_italic placeholder_` with real content
  based on what the user told you. If you genuinely lack the information for a section, ask the
  user (one question at a time) rather than inventing facts. Drop sections only when the
  template says they are optional and the user has nothing to add (e.g. *Testing Scenarios*).
- **Ask when anything is unclear:** Prefer asking over guessing. Whenever the request is
  ambiguous or incomplete, ask clarifying questions (one at a time, each with a recommendation)
  before writing. It's better to ask a few questions than to invent details.
- **Confirm the user story BEFORE writing the full ticket:** Don't write the whole ticket in
  one shot. First propose your best-guess *user-story sentence* (see *User story* below) as an
  assumption, and ASK me whether I agree or want it different. Only after I've confirmed the
  user story do you write out the rest of the ticket.
- **Reference other tickets sparingly:** Mentioning a related ticket is good, but don't
  overdo it. Cite a given ticket number only once — ideally in one dedicated spot (e.g. a
  "Related" note) — rather than repeating the same `#<number>` across multiple sections. One
  clear reference beats the same ticket sprinkled everywhere.
- **Problem first (bugs & tasks):** For **bug** and **task** tickets, keep the *problem* in the
  foreground — describe what is wrong or what is needed and why it matters (the impact), not how
  to fix it. You MAY suggest a possible solution, but clearly mark it as a suggestion and state
  that the final decision on how to solve it is left to whoever picks up the ticket. Never write
  the ticket as if a particular implementation is already decided. (Features may describe the
  expected behaviour in more detail, since that defines the feature.)

## Picking the category (ALWAYS ask — never decide yourself)

ALWAYS ask the user which category the ticket is before writing it — **Bug**, **Feature**,
**Task**, or another type they name. Do NOT decide the category yourself, even if it seems
obvious from their description. You may state which one you'd guess, but you must still ask and
let the user confirm or correct it before proceeding.

- **Feature** — new capability or enhancement.
- **Bug** — something is broken / behaves wrong. Push for more reproduction detail in
  AS-IS-STATE (concrete examples, links, mailboxes, steps).
- **Task** — a unit of work that is neither a new feature nor a defect (chore, setup, follow-up).

All three share the same section structure below. The only practical difference is emphasis:
bugs need strong reproduction detail in AS-IS-STATE.

## User story

Write the User Story / Description as a single sentence in this structure:

> **As a** _(the user role)_ — who needs this (e.g. customer, admin, guest).
> **I want to** _(the action)_ — the specific capability or behaviour they want.
> **So that** _(the value)_ — the underlying goal, reason, or business value.

Example — *As a registered user, I want to reset my password via an email link so that I can
regain access to my account if I forget my password.*

Remember the workflow rule above: propose this sentence first as your best guess and get my
agreement on it BEFORE writing the full ticket. For a bug or task where a user-story sentence
doesn't fit naturally, say so and offer to phrase the core problem / acceptance criteria
instead — still confirm the framing with me first.

## Template

Two parts: the **core** (always present) and **optional** sections (include only when they add
concrete info not already stated). Keep every part short - bullets over paragraphs.

### Core (always)

```
**Title (Redmine Subject):** <title - prefix with `[TT] ` if technical>

#### Description
_one line. feature: `As a (role), I want to (action) so that (value).` bug/task: the problem in one sentence._

#### AS-IS
_bugs: concrete repro detail (examples, links, mailboxes, steps). omit for a pure feature with no current behaviour._

#### TO-BE / Acceptance Criteria
_the expected result AND the conditions to consider it done, as short bullets. state the result, not a prescribed implementation. if an official spec applies (e.g. Tradacoms), quote the exact section + link once._

#### Priority
_low | medium | high_
```

### Optional (add ONLY if it adds new info, else omit the heading entirely)

```
#### Possible Solution
_bugs/tasks only: a suggested approach, clearly marked a suggestion - the person working it decides. omit if none._

#### Customer Impact
_only if it adds something the user story's "so that" didn't already say. reusable for Release Notes._

#### Actors
_only if non-obvious from the user story: internal/external; retailer- or supplier-based; specific customer name if one._

#### Testing Scenarios
_only if you have specific testing instructions worth stating._
```

## Output

Follow the global "Writing text deliverables" rules:

1. Write the ticket to a file with the **`.md`** extension — never just print it in chat.
2. Location: `<repo-root>/notes-local/<release>/#<ticket>-<slug>/`, e.g.
   `notes-local/release_3.18/#43134-mixed-vat/ticket.md` (never use whitespace in these paths -
   use `_`). If you don't know the release,
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
