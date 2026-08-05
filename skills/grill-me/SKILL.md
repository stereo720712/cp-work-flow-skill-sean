---
name: grill-me
description: >
  Relentless one-question-at-a-time interview for sharpening a plan, requirement, workflow, or design decision. Use when the user asks to use grill-me, says grill this, or wants to stress-test thinking before acting.
---

# Grill Me

Use this skill to stress-test a plan, requirement, workflow, or design until the user and agent reach shared understanding.

## Core behavior

- Ask one question at a time.
- For each question, provide your recommended answer first, with brief reasoning.
- Wait for the user's response before moving to the next question.
- Walk dependencies in order: resolve prerequisite decisions before downstream decisions.
- If a fact can be discovered from files, git state, code, templates, or tools, inspect it instead of asking.
- Decisions belong to the user; do not proceed with document generation or implementation until the user confirms the decision path.

## Question format

Use this shape:

```markdown
第 N 問：{decision question}

我的建議答案：{recommended answer}

理由：{short reasoning}

你同意嗎？
```

If the user agrees, continue to the next unresolved decision. If the user disagrees, adjust the decision tree and ask the next most important question.

## Stop condition

Stop grilling when:

- all blocking decisions are answered,
- remaining unknowns are explicitly marked as acceptable follow-up items, and
- the user confirms the shared understanding.

Then summarize the confirmed decisions and the files that should be updated next.
