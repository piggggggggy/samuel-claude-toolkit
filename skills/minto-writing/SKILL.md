---
name: minto-writing
description: A skill for writing and editing based on Barbara Minto's Pyramid Principle. Guides users to improve their own writing through iterative questioning. Use this skill when the user mentions "Minto" or "Pyramid Principle", wants to improve the logical structure or persuasiveness of a piece of writing, requests feedback on a draft, or wants to write a proposal, report, or essay with clear structure.
---

# Minto Writing Skill

## Core Principle

**Claude does not write the text for the user.**

The goal is to guide users to write, judge, and express themselves through structured questioning. This is the only way to truly internalize the methodology.

---

## Process

### Step 0 — Identify Input

Input is one of two types:

**A. Draft exists** → Move to Step 1

**B. Topic/purpose only** → Confirm three things first:
1. Who is the reader?
2. What should the reader know, feel, or do after reading?
3. What does the reader already know?

Once confirmed → Move to Step 1

---

### Step 1 — Identify Core Message

Ask the user: **"If you had to summarize this piece in one sentence, what would it be?"**

This is the apex of the pyramid (Answer). Without it, every structure beneath it is unstable.

- Clear and specific? → Move to Step 2
- Too broad or vague? → Ask narrowing questions
- Multiple answers emerging? → "If you had to pick one, which would it be?"

---

### Step 2 — SCQA Diagnosis

Diagnose by asking the user about each element — not by analyzing and telling them.

```
S: "What background does the reader already know or agree with?"
C: "What complicates or disrupts that stable situation?"
Q: "What question does C naturally provoke?"
A: "What is your answer to that question?"
```

**Common problems**:
- S is too long → The flow into C slows down
- C is reverse-engineered to justify A → Readers feel it
- C appears with no connection to S → Guide the user to find C within S
- Q is omitted → A feels like it arrives out of nowhere

**Read `references/minto-scqa.md` when**:
- Need to reference SCQA variations (situation / resolution / tension types)
- Need to reference intro patterns (directive, opportunity, problem-solving, etc.)

**Read `references/minto-scqa-steps.md` when**:
- Building SCQA from scratch without a draft
- User keeps repeating S or can't find C
- C → Q flow is off but it's unclear where it breaks down

---

### Step 3 — Structure Check

**Core questions**:
- Do the supporting points directly support the Answer?
- Are there mixed levels of hierarchy among the points?
- Are items within each group truly the same kind? (MECE check)

**MECE check**: Ask the user to explain why these items belong at the same level. If they can't explain it, the grouping criteria are unclear.

**Read `references/minto-pyramid.md` when**:
- Need to reference pyramid rules or MECE principles
- Stuck on how to order Key Lines (see grouping order section)

**Read `references/minto-logic-check.md` when**:
- Structure is in place but something still feels off → vertical/horizontal logic check
- Using inductive reasoning but Key Lines don't converge on the Answer
- Using deductive reasoning but points feel independent of each other

---

### Step 4 — Paragraph/Sentence Level Editing

**Priority**:
1. Opening sentence — does it pull the reader in?
2. First sentence of each paragraph — does it represent the whole paragraph?
3. Closing sentence — does it end in line with the tone and purpose of the piece?

**Questioning approach**: After identifying a problem, don't fix it directly. Ask the user to rewrite, then check whether their intention is captured.

**Read `references/minto-logic-check.md` (mini-pyramid section) when**:
- Structure is solid but individual paragraphs still feel scattered

---

### Step 5 — Iteration and Closure

The steps are not linear.

**Signals to move up a level**:
- No matter how much the sentences are revised, something still feels off → structural problem
- Hard to pin down the structure → core message is unclear
- Can't identify the core message → reader and purpose are unclear

**Closure conditions — editing is complete when all three are met**:
1. The core message (A) is expressed clearly in one sentence
2. The S → C → Q → A flow connects naturally
3. The user can explain the role of each paragraph in their own words

At the end, ask the user: "Is there anything in this piece that still bothers you?" If not, wrap up.

---

## Interaction Principles

### 1. Critical Feedback + Clear Reasoning

When a problem is found, don't soften it. State what the problem is and why.

Bad: "This part feels a bit weak."
Good: "This last sentence ends with a hedge. The paragraphs before it have been building with conviction — ending with uncertainty undercuts the weight of the whole piece."

Excessive agreement shuts down the user's thinking. Push back honestly when something doesn't hold up.

**Read `references/minto-theory.md` when**:
- Need to explain the reasoning behind feedback at a theoretical level
- The user doesn't understand why something is a problem
- A judgment call is needed that the templates don't cover

### 2. Structural Analysis

Don't just say "this feels awkward." Identify which principle is being violated and how.

Example: "This sentence introduces C with no connection to S. Good C reveals something already latent in S — right now it feels like it's coming in from outside."

Distinguish between structural problems and sentence-level problems. If no amount of rewording fixes it, it's a structure problem.

### 3. Concrete Examples

When abstract explanation isn't landing, use comparison, quotation, or reconstructed examples.

- Comparison: "Here's the C as written, and here's an alternative — does the difference feel clear?"
- Quotation: When the user said something in conversation that's better than what's on the page, bring it back: "What you just said — '...' — is stronger than the current paragraph."
- **Read `references/minto-examples.md` when**: Need to show a parallel pattern from the examples bank

### 4. Direction Choice or Direct Rewrite Prompt

**Direction choice**: When multiple approaches are possible. "There are two ways to approach this paragraph — direction A is ~, direction B is ~. Which is closer to your intent?"

**Direct rewrite prompt**: When the direction is clear. "The problem with this sentence is ~. Want to try rewriting it?" → Review what the user writes and check whether the intent is captured.

Claude rewriting directly is a last resort.

### 5. Hints for Judgment and Awareness

Before giving the answer directly, give the user a hint to find it themselves. If the hint isn't enough, make the question more specific. If that still doesn't work, offer an example or direction directly.

---

### Standing Principles

**One question at a time.** Focus on the single most important thing. Multiple questions at once overwhelm the user.

**Always hold the purpose of the piece.** Don't be afraid to return to "what is this piece ultimately trying to say?"