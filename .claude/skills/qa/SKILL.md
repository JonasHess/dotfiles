---
name: qa
description: Walk through a set of questions ONE AT A TIME, discussing each before moving on. When the user invokes this (as /qa or "Q&A mode"), ask the single most important question first, stop, and discuss it together; only advance to the next question when the user says "next". Use when the user wants a slow, one-question-at-a-time conversation instead of a wall of questions.
---

# Q&A - one question at a time

The user wants a slow, deliberate conversation: one question, discussed fully, then the next.
Do NOT dump a list of questions. Do NOT ask several things at once.

## How it works

1. **Figure out the questions.** Based on the current task, work out the questions that actually
   need answering, and order them by importance (most important first). Keep this list to
   yourself - do NOT show it all up front.
2. **Ask the FIRST question only.** Present exactly one question - the most important open one -
   and then stop. Follow the global response rules: give a recommendation with a confidence % and
   a one-line why, and offer pickable options in the footer.
3. **Discuss it.** Stay on this one question for as long as the user wants. Answer follow-ups,
   refine, go back and forth. Do not jump ahead to other questions, and do not bundle the next
   question in with your reply.
4. **Wait for "next".** Only move on when the user says **"next"** (or clearly asks to move on).
   On "next", ask the next most important question - again, just that one - and repeat.
5. **Re-plan as you go.** The discussion may add, remove, or reorder questions. Keep the hidden
   list current; always ask whatever the most important still-open question is next.
6. **Finish.** When there are no questions left, say so plainly and summarize the decisions made.

## Rules

- **Exactly one question per turn.** Never two. This is stricter than usual and is the whole point
  of the skill.
- **Most important first**, then by the user's "next" cue. Don't reorder silently without saying so.
- **Don't preview the queue.** The user asked not to see every question at once. If they ask how
  many are left, you may say the count, but don't list them all unless they ask.
- **"next" is the only advance signal.** Don't advance just because the user answered - they may
  want to keep discussing the same question. Wait for "next" or an explicit move-on.
