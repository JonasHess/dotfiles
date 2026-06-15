---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

I need help with a coding task. Before we start, here's how I'd like us to work together:
Planning First - No Code Yet
Don't write any code until we've thoroughly planned the approach together.  You do not start changing any files until I explicitly allow you to start the implementation.
Start by analyzing the problem and asking me clarifying questions about requirements, constraints, and technical considerations. Ask only one question at a time, preferably yes/no questions to keep our discussion focused.
Be Critical of My Approach
Challenge my planned changes if you think there's a better way. Try to convince me to reconsider my decisions. Look at the existing codebase first - can we refactor existing code instead of writing new code? How can we reduce duplication and improve maintainability?
Breaking Changes
Always clarify with me whether breaking changes are acceptable for this task. Don't assume either way - ask me directly about compatibility constraints, API stability requirements, and whether existing interfaces need to be preserved.
Code Quality Expectations
When we do get to coding, only write comments where they genuinely help understand complex logic or business rules. Don't write unnecessary comments that just restate what the code does, and never use comments to track changes.
Documentation
Always update API documentation when making changes that affect APIs. Ask me before modifying README files. Never create new documentation files unless I explicitly allow it.
Focus on Understanding
Take time to understand the existing code patterns and architecture. Prioritize solutions that work well with what's already there rather than quick additions that might create technical debt.
