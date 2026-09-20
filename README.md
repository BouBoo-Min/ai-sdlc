# AI-Native SDLC — reusable workflow repo

English | [简体中文](README.zh-CN.md)

A ready-to-inherit implementation of Anthropic's [AI-Native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) (see also the reference implementation at [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc)): give your coding agent a goal or idea, and it scaffolds and drives the project through the full lifecycle — **Plan → Design → Build → Test → Deploy → Maintain** — with human approval gates at every handoff.

This repo is a **skill** at `skills/ai-sdlc/`, installable into `~/.codex/skills` (Codex) or `~/.claude/skills` (Claude Code), and a **Codex plugin** (`.codex-plugin/plugin.json` at the repo root) that bundles it.

## What this is about

Writing code is no longer the bottleneck — agents produce it in hours. The bottleneck moved to the process around the code: planning, review, deployment, and governance still run at human speed and human scale. This repo reworks the SDLC so those stages keep up with the build:

- The loop is **Plan → Design → Build → Test → Deploy → Maintain**; every stage ends by committing a versioned artifact the next stage reads.
- Human judgment concentrates at **gates** instead of line-by-line review.
- Guardrails run as **deterministic hooks** rather than habits.
- Continuous **evals** replace stage-gate QA.

The operating principle, in one sentence: **the agent can do everything up to the production gate, but never crosses it.**

## The workflow

```
Plan → Design → Build → Test → Deploy → Maintain
  ↑                                             │
  └───────────────── back to Plan ←─────────────┘
```

| Phase | Reads | Produces | Gate (human approval) |
|---|---|---|---|
| Plan | user's idea | `iterations/current/intent.md` | accepted → Design |
| Design | intent + standards | `iterations/current/spec.md` | approved → Build |
| Build | intent + spec | `plan.md` → code + tests → PR | plan approved; PR merged → Deploy |
| Test | repo + eval suite | eval results, regression evals | config changes that drop pass rate are reviewed |
| Deploy | merged PR | authorized release | explicit release authorization |
| Maintain | production metrics | diagnosis → new `intent.md` | on-call triage |

The phase → artifact → gate contract lives in [`skills/ai-sdlc/SKILL.md`](skills/ai-sdlc/SKILL.md) (single source of truth). The machine-readable graph state is `workflow-graph.yaml` — the one skeleton file that stays at a project's root; everything else lives under `iterations/` (including `REVIEW.md`, `bands.yaml`, and the optional agent org).

## Install

### As a Codex skill

```bash
mkdir -p ~/.codex/skills
cp -R skills/ai-sdlc ~/.codex/skills/
```

### As a Claude Code skill

```bash
mkdir -p ~/.claude/skills
cp -R skills/ai-sdlc ~/.claude/skills/
```

### As a Codex plugin

Clone or copy this repo, then add it to your personal marketplace at `~/.agents/plugins/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "ai-sdlc",
      "source": { "source": "local", "path": "./ai-sdlc" },
      "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
      "category": "Productivity"
    }
  ]
}
```

Installing the plugin also makes the bundled skill available — choose one path, not both.

## Use it

Start a new project:

```bash
python3 skills/ai-sdlc/scripts/init_workflow.py my-project --name "My idea"
```

Then tell your agent:

> $ai-sdlc: I want to build an expense tracker. Start with the intent.

The agent interviews you until the idea is concrete, writes `iterations/current/intent.md`, commits it, and asks you to accept. From there it moves through spec → plan → build → test → deploy, stopping at each approval gate, and finally wires up monitoring so the loop can close back into new intents.

Already have a project? Scaffold into it directly:

```bash
python3 skills/ai-sdlc/scripts/init_workflow.py .
```

The skeleton does not create `CLAUDE.md`/`AGENTS.md` or `.gitignore` — keep your own repository-memory file and ignore rules.

## Autonomous agent org

For teams that want the loop to run with less human steering, the skill can scaffold an **agent org** into any project — named roles with an org chart, peer review of every artifact, and multi-channel demand intake:

```bash
python3 skills/ai-sdlc/scripts/init_org.py my-project
```

The default org: **CEO (you, human)** → **CTO (agent)** → product manager, product engineering agent, engineers, and reviewer. Agents run the phases, review each other's work, and escalate to the human CEO only at the critical gates (intent ambiguity, unresolved disagreement, PR merge, release). Everything lands under `my-project/iterations/org/`.

See [`skills/ai-sdlc/references/org.md`](skills/ai-sdlc/references/org.md) for the full protocol.

## Customizing for your organization

- **Standards as skills** — encode brand, security, UX, and compliance policies as skills so Design and Build apply them consistently.
- **Hooks as red lines** — protected paths, secrets, and the release gate go in deterministic hooks, not prose. `production-gate.sh` blocks deploys without human authorization (`tests/test_gate.sh` is its test suite); `hook-settings.example.json` shows the wiring.
- **Evals** — collect real tasks with expected outcomes; run them in CI on every config change and after every incident (`agent-evals.yml.example`).
- **Review culture** — `iterations/REVIEW.md` sets the soft rules for the AI PR-review loop: passes (bugs, security, compliance), the evidence requirement, and the 5-nit cap.
- **Monitoring tiers** — `iterations/bands.yaml` defines 1σ/2σ/3σ responses; at 3σ the agent may act only by opening a PR into the review gate or triggering a pre-approved runbook.

## Development

Validate the bundle (frontmatter, links, plugin manifest, YAML/JSON assets, shell syntax, gate tests, scaffold smoke test):

```bash
python3 skills/ai-sdlc/scripts/quick_validate.py
```

## References

- [The AI-Native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) — the Anthropic blog post this workflow implements.
- [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc) — the reference repo this project's structure follows.
