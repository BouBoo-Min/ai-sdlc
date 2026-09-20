# Changelog

All notable changes to this project are documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [SemVer](https://semver.org/).

## [Unreleased]

### Added

- Root `README.md` (English) and `README.zh-CN.md` (简体中文), cross-linked; content modeled on [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc) and Anthropic's [AI-Native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook).
- `CHANGELOG.md` (this file).
- `tests/test_gate.sh` — release-gate test suite (7 cases: unauthorized deploy blocked, read-only allowed, non-deploy allowed, staging allowed, valid authorization passes, expired authorization fails closed).
- `.codex-plugin/plugin.json` — Codex plugin manifest bundling the skill.

### Changed

- Repository restructured to the upstream layout: the entire skill moved to `skills/ai-sdlc/` (`SKILL.md`, `assets/`, `scripts/`, `references/`, `agents/`).
- Scaffold (`init_workflow.py`) reworked so every skeleton artifact lives under `iterations/` except `workflow-graph.yaml`, which stays at the repo root:
  - `REVIEW.md` → `iterations/REVIEW.md` (now documented as soft rules only for the AI-in-PR-review loop; passes, severity, 5-nit cap, skip list — no ownership of branch protection/approvals/merges).
  - `bands.yaml` → `iterations/bands.yaml` (documented as Maintain-phase config for `detect_bands.py`).
  - `CLAUDE.md`/`AGENTS.md` and `.gitignore` are no longer scaffolded; teams keep their own repository-memory file and ignore rules.
  - Agent org (`init_org.py`) now scaffolds into `iterations/org/` (org chart, status, protocol, roles, intake, reviews, tool scripts); runtime defaults in `org_status.py`, `sync_issues.py`, and `intake.py` follow the new paths.
- `iterations/README.md` template now documents every file in the directory: iteration trio, root-level `REVIEW.md`/`bands.yaml`, `org/`, `hooks/`, `scripts/`, `gates/`, `evals/`, plus the root `workflow-graph.yaml`.

## [0.1.7] — 2026-09-18

### Added

- Deterministic gate enforcement: `workflow_state.py close` (ledger record + graph advance in one step), `check --strict` drift detection, `gate_ledger.py` hash-chained approval ledger.
- `production-gate.sh` release authorization hook with expiry and ledger-backed approvals.
- `check_plan_sync.py` plan-vs-diff enforcement; `detect_bands.py` control-band detection; `run_evals.py` eval runner.
- Autonomous agent org scaffold (`init_org.py`) and demand intake (`sync_issues.py`, `intake.py`, `org_status.py`).

## [0.1.0] — Initial release

### Added

- AI-native SDLC skill: Plan → Design → Build → Test → Deploy → Maintain with human approval gates at every handoff.
- Artifact templates (`intent.md`, `spec.md`, `plan.md`, `REVIEW.md`, `bands.yaml`), scaffold script, and workflow graph.
