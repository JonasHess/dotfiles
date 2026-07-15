---
name: catch-me-up
description: Explain and summarize the current situation in plain, easy-to-understand language when the user has lost track of what Claude is doing or doesn't understand what Claude is asking. Use when the user says they can't keep up, are confused, are lost, or asks to have things explained simply.
---

The user has lost the thread — they can't follow what you're doing or don't understand
what you're asking of them. Stop making progress on the task and help them catch up.

## How to respond

1. **Pause the work.** Don't take any new actions, don't edit files, don't run commands.
   Right now the only job is to get the user back on the same page.

2. **Summarize the situation in plain language.** Cover, briefly:
   - What we set out to do (the goal, in one sentence).
   - What has happened so far / where we are right now.
   - What (if anything) I'm currently waiting on from you, and why.

3. **Use easy-to-understand language.**
   - Short sentences. No jargon. If a technical term is unavoidable, explain it in
     parentheses the first time (e.g. "rebase (replaying our changes on top of the
     latest code)").
   - Prefer everyday analogies over precise-but-dense wording.
   - Assume the user is smart but has not been following the details — don't condescend,
     don't dump walls of text.

4. **If I asked you a question you didn't understand, re-ask it more simply.**
   - Restate what I'm actually deciding and why it matters.
   - Lay out the options concretely, including what happens with each choice.

5. **Give a clear recommendation with a confidence score.**
   - Say which option I'd pick and why, in one line.
   - Add a confidence % (~90% = very confident it's right, ~10% = likely a bad choice).
   - If several things are open, recommend the single most important next step first.

6. **Ask only one question at a time.** After the summary, if you still need a decision,
   ask just one clear question so the user isn't overwhelmed. Offer to explain anything
   in more detail if they want.

Keep the whole thing short enough to actually read. The goal is relief, not another
thing to wade through.
