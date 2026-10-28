---
name: edi-specs
description: Find and read official EDI specifications (EDIFACT / GS1 EANCOM, EDItEUR book trade guidelines, BIC TRADACOMS, ANSI X12 from PubNet and BookNet Canada) in the pubx-edi-reference repo, and add missing ones there. Use whenever a task needs what a spec says - a segment, element, code value, status (M/C/R/N), length, message structure, envelope (UNB/UNH, STX, ISA/GS) - or when checking pubx EDI code (ORDERS, ORDRSP, DESADV, INVOIC, TAXCON, 850, 855, 856, 810, 857, 997, TRADACOMS ORDHDR/ACKHDR/INVFIL ...) against a standard. Never answer spec questions from memory.
---

# EDI specs - use the pubx-edi-reference repo

All official EDI spec documents that matter for pubx live in ONE git repo:
**`pubx-edi-reference`** (remote `git@gitlab.dev.booklan.de:pubx/pubx-edi-reference.git`).
It is the single source of truth. Do not answer spec questions from memory, from what the existing
code does, or from the web before you have looked there.

## 1. Find the repo

The repos live under `~/repos/<name>` or `~/IdeaProjects/<name>` depending on the machine. Check:

```bash
ls -d ~/repos/pubx-edi-reference ~/IdeaProjects/pubx-edi-reference 2>/dev/null
```

If neither exists, clone it next to the other repos (`git clone git@gitlab.dev.booklan.de:pubx/pubx-edi-reference.git`).
If the clone fails because the host is unreachable, it is probably the VPN: stop and ask the user to
connect it. If the repo exists, a quick `git -C <repo> pull --ff-only` keeps it current; if that
cannot fast-forward, tell the user instead of resolving it yourself.

## 2. Read its README first - always

Open **`<repo>/README.md`** fresh every time (it changes; do not rely on what you remember of it).
It explains the layout, the "Find by message" table (order, order response, despatch, invoice,
envelope ... across EDIFACT / TRADACOMS / X12) and the rules for adding documents. Then open the
format README it points to (`edifact/README.md`, `tradacoms/README.md`, `x12/README.md`): those list
every document with what it covers, and hold notes on values that were already verified.

The layout, in short (the README is authoritative if this ever differs):

```
<format>/<publisher-or-community>/
  original/    documents exactly as published (PDF, XLS, GS1 EANCOM HTML mirror) - the authority
  markdown/    Docling Markdown copy of each PDF, same base name (<name>.md) - for reading and grep
```

## 3. Read the spec

- **Start with the Markdown copy** (`markdown/<name>.md`): it is text, grep-able and cheap to read.
  For the GS1 EANCOM messages use the HTML mirror under `edifact/gs1-eancom-2002/original/html/`
  (one page per segment; `part3/` holds the code lists).
- **Confirm every value you rely on against the original.** The Markdown copies have known table
  flaws (repeated spanning cells, occasionally merged rows, code lists displaced after a page break,
  single dropped cells) and say `Reviewed: no` in their header until someone has checked them. Check a
  table value in the PDF with `pdftotext -layout -f <page> -l <page> <pdf> -` or by reading the PDF
  pages with the Read tool (`pages` parameter).
- `scripts/check-conversion.py -v <pdf>` in the repo lists what a Markdown copy is missing compared
  with the PDF's text layer.
- In answers, cite the document path and section/page, and say whether you checked the original.

Distinguish the layers - they can disagree, and the more specific one wins for pubx's partners:
UN/EDIFACT -> GS1 EANCOM (generic subset) -> EDItEUR guideline (book trade usage) -> BIC (UK usage).
For X12: BISAC/PubNet (US Trade, US ECPA, version 3060) and BookNet Canada (version 4010) differ.

## 4. A spec is missing - add it to the repo

If the document you need is not in the repo, do not just read it from the web and move on: add it, so
the next lookup finds it. Follow the "Adding something" section of the README; in short:

1. Find the **official** source (publisher's site) and the exact document/version. If you cannot find
   it, ask the user for it instead of guessing the content.
2. Add a `"<path>|<url>"` entry to `scripts/download-specs.sh` and run it (some sites, e.g.
   bic.org.uk, block scripts - the script lists those; fetch them in a browser and save under the
   listed path). For another GS1 EANCOM message, use `scripts/mirror-eancom-2002.sh` instead.
3. Convert the PDF with `scripts/convert-pdfs.py` (setup and run instructions are in the README) and
   check it with `scripts/check-conversion.py`.
4. Add a row to the format README (and to "Find by message" if it is a message guideline).
5. Commit in that repo using the ticketed profile, e.g.
   `Ref #44597 documentation - add <document>`. Commits and pushes need the user's explicit OK
   each time, as everywhere else.

Never edit a file in `original/`. Notes about what a document says go into the format README.

## Do not

- Do not store new spec documents in a repo's `notes-local/spec/` - that location was retired; the
  pubx clone's `notes-local/spec/README.md` only points to this repo.
- Do not treat a Markdown copy as authoritative for a value you have not checked in the original.
- Do not infer spec rules from pubx code or test fixtures - they may be wrong; that is often exactly
  what is being checked.
