# Review standards

> **Scope (soft rules only).** This file is the review-standards piece of the
> "AI deeply embedded in the PR review loop" play. It defines *soft* rules —
> passes, severity language, nit caps, skip lists — that guide how the agent
> reviews. It does **not** own branch protection, approvals, merges, or any
> deterministic enforcement; those are gates handled elsewhere (plan.md sync,
> workflow graph, gate ledger). This file lives under `iterations/` like every
> other process artifact; only `workflow-graph.yaml` stays at the repo root.

Applies to agentic review passes. Evidence before opinions.

## Passes

Run three passes and tag each finding with its pass:

- Bugs: logic errors, broken edge cases, subtle regressions
- Security: injection risks, authentication gaps, PII in logs
- Compliance: the change matches spec.md, plan.md, and our design principles

## What Important means here

Reserve Important for findings that would break behavior, leak data, or breach a policy. Style and naming are nits.

## Cap the nits

Report at most five nits per review; summarize the rest as a count.

## Do not report

Generated files under src/gen/ and anything CI already enforces.

## Human review

Findings do not approve or block on their own; branch protection requires code owner approval. Humans answer two questions:

1. Is this the change the plan intended?
2. Is the risk acceptable?

Line-by-line human review is reserved for regulated and critical-path code.
