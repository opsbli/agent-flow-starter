# Agent Flow Adoption Guide

> **For teams who want to adopt agent-flow in a real project.**
> This file helps you go from "installed" to "actively using in daily development."

## Step 1: Install and Initialize

```bash
# From this starter repo
bash scripts/install-agent-flow.sh --target /path/to/your-project

# Then inside your project
cd /path/to/your-project
bash agent-flow/scripts/init-project.sh
bash agent-flow/scripts/scaffold-health.sh
```

See `agent-flow/FAQ.md` for troubleshooting.

## Step 2: Run Your First Light Change

Pick the smallest possible request — a README fix, a comment correction, or a single-file bug fix:

1. Ask your AI to "run agent-flow for this task"
2. AI creates `agent-flow/changes/my-first-change/`
3. AI writes `STATE.md`, `CHANGE.md`, `CODE_SCAN.md`, implements, writes `VERIFY.md`, `REPORT.md`
4. You review

**Expected time**: 5-10 minutes. If it takes longer, something is off.

## Step 3: Run Your First Standard Change

Pick a well-defined single-module feature with clear acceptance criteria:

1. The AI runs code scan, writes `DESIGN.md`, and performs Design Alignment (asks you 3-5 questions)
2. You confirm the design
3. AI writes `TASKS.md`, implements, runs `task-check`, writes `VERIFY.md`
4. You verify AC coverage

**Expected time**: 15-30 minutes of AI work + 5 minutes of your review.

## Step 4: Run Your First Heavy Change

Pick a cross-module feature or something that touches the database:

1. Full Heavy workflow: Grill → Code Scan → Design → Design Alignment → Plan Audit → Implementation → Verification → Closure Audit
2. You approve or reject the Plan Audit
3. AI implements phase by phase
4. AI runs `code-drift-check`, `blocked-check`, `coverage-check`
5. You review the Closure Audit

**Expected time**: 1-2 sessions. This is where agent-flow's value really shows.

## Evidence That It's Working

After 5-10 changes, you should see:

- **`agent-flow/knowledge/`** filling up with terms, mapping, and pitfalls specific to your project
- **`agent-flow/knowledge/known-good-baselines.md`** with build/test baseline records
- **`agent-flow/changes/`** with multiple completed changes
- **`agent-flow/logs/YYYY/`** with day-level session records
- **AI asks better questions** about your design instead of coding blindly

Run `evolution-stats` to see the aggregate picture:

```bash
bash agent-flow/scripts/evolution-stats.sh --update-index
```

## Common Adoption Patterns

### Pattern A: "I trust my AI on small stuff"

- Light changes: let AI run autonomously (autonomy: implement-safe)
- Standard changes: require Design Alignment before implementation
- Heavy changes: always require Plan Audit and Closure Audit

### Pattern B: "I want to review everything"

- Set default autonomy to `plan-first` in manifest.yaml
- Every change, even Light, requires your explicit approval before write

### Pattern C: "We're in incident response mode"

- Use Emergency channel for P0/P1 incidents
- Schedule a "backfill session" within 24 hours
- After 3 incidents, run a root cause analysis and update pitfalls

## Signs You're Using Too Much Process

- You're spending more time writing change docs than implementing
- Your AI spends 20 minutes filling templates for a 2-line fix
- Design Alignment questions feel irrelevant to tiny changes

**Fix**: Let AI use `Light` route for single-file fixes and docs-only changes. Don't force Standard/Heavy on trivial work.

## Signs You're Using Too Little Process

- AI wrote code that duplicated existing functionality (should have been caught by CODE_SCAN)
- AI modified files outside the intended scope (should have been caught by task-boundary-check)
- AI declared completion without running tests (should have been caught by VERIFY.md requirements)
- Design misalignment had to be fixed during rework (should have been caught by Grill)

**Fix**: Be stricter about not skipping gates. Run `check-change` before declaring done.
