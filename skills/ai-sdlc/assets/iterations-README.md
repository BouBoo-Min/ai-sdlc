# iterations/ — AI-Native SDLC 工作目录说明

本目录是 AI-Native SDLC 回路的全部运行时工件：每轮迭代的产物、门禁工具、
审批台账与评估套件都收在这里。活的迭代固定在 `current/`；已完成的迭代
按 `NNN-<合并commit短SHA>-<slug>/` 归档（如 `001-4f26f9f-claims-portal/`，
序号保证排序，短 SHA 可回溯到合并提交）。

## 目录与文件一览

### `current/` — 当前活跃迭代（三件套）

| 文件 | 阶段 | 说明 |
|---|---|---|
| `intent.md` | Plan | 需求意图：问题现状、期望结果、涉及系统、约束、待确认问题。由产品负责人从模板生成并提交，接受后进入 Design |
| `spec.md` | Design | 需求+技术规格：结合组织规范（CLAUDE.md/Skills）推导，显式标注关注点与政策冲突，产品负责人批准后进入 Build |
| `plan.md` | Build | 实施计划：受影响文件清单、实施顺序、风险与应对、验证依据。工程师批准（plan 门禁）后 AI 才开始写代码；PR 审查以它的 "Files that change" 为核对清单 |

迭代闭环后，把整个 `current/` 重命名归档（`git mv iterations/current iterations/NNN-<short-sha>-<slug>`），
新一轮的 `intent.md` 草稿写回 `iterations/current/intent.md`。不要发明新的活路径
（如 `iterations/002/`）——工作流工具只认 `iterations/current/`。

### 根级过程文件

| 文件 | 说明 |
|---|---|
| `REVIEW.md` | AI 深度融入 PR 评审循环的**软规则**：三轮评审 pass（Bugs/Security/Compliance）、Important 的判定标准、每次评审最多 5 条 nit、跳过清单（生成文件、CI 已强制项），以及人类评审要回答的两个问题。它只指导 agent 怎么评，不拥有分支保护/批准/合并——那些由门禁体系处理 |
| `bands.yaml` | Maintain 阶段的生产监控控制带配置：为每项指标定义基线（滚动 30 天）、检测规则（Western Electric）和 1σ/2σ/3σ 分级动作（log / 只读诊断 / 开 PR 或触发预批准 runbook）。是 `scripts/detect_bands.py` 的输入；改分级或路由在这里改，不改代码 |

### `org/` — 自治 agent 组织（由 `scripts/init_org.py` 脚手架，可选）

| 文件/目录 | 说明 |
|---|---|
| `org-chart.yaml` | 角色模型：谁向谁汇报、各角色的权限与把守的门禁 |
| `status.yaml` | 各 agent 的实时状态（busy/idle）与评审队列，由 `scripts/org_status.py` 维护 |
| `protocol.md` | 组织协议：任务分派、同行评审、升级与需求摄入的流程规则 |
| `roles/*.md` | 角色卡（CEO-human、CTO、product-manager、product-engineer、engineer、reviewer），每张卡写明职责与读写哪些文件 |
| `intake/` | 多渠道需求摄入：`config.json`（GitHub 仓库/标签配置）、`github/`（`sync_issues.py pull` 拉取的 issue）、`forms/`、`email/` |
| `reviews/` | 评审记录：每份工件一个 markdown，含按严重度排序、带文件/行号证据的发现 |
| `scripts/` | 组织工具脚本（`sync_issues.py`、`org_status.py`、`intake.py`）的落地副本 |

### `hooks/` — 确定性护栏

| 文件 | 说明 |
|---|---|
| `production-gate.sh` | 生产部署门禁（PreToolUse hook）。检测到 deploy+production 命令时要求 `RELEASE_APPROVAL` 环境变量；支持 `ledger:<record-id>` 形式——会到台账里校验该记录存在、已批准、未过期且已提交。可用 `GATE_LEDGER_SCRIPT` / `GATE_LEDGER_FILE` 覆盖默认路径 |

### `scripts/` — 门禁与回路工具（无模型输入，全部确定性执行）

| 文件 | 说明 |
|---|---|
| `gate_ledger.py` | 哈希链审批台账。`record` 记账、`list` 查询、`verify` 校验单条记录；每条记录含 gate/decision/artifact/approver/evidence/时间戳与 `prev_hash`/`hash`，防篡改。默认台账 `iterations/gates/ledger.jsonl` |
| `workflow_state.py` | 工作流状态机。`status` 看回路状态、`close` 一步过门禁（记账+推进节点，防止状态与台账漂移）、`advance` 用已有记录推进、`check --strict` 校验图/账一致（后阶段工件存在但前门禁无记录会报错）、`preflight` 供 hook 调用 |
| `check_plan_sync.py` | plan 同步检查。PR 模式对比 diff 与 plan.md 的 "Files that change"；pre-commit 模式校验暂存文件；无 plan 或计划外文件即失败 |
| `run_evals.py` | 运行 eval 套件（Phase 4），`--min-pass-rate` 门禁，`--record` 把每次运行追加到 `iterations/evals/results/` |
| `detect_bands.py` | 监控控制带检测（Phase 6 参考实现）：滚动窗口、Western Electric 规则、漂移规则，输出 1σ/2σ/3σ 分级动作 |

### `gates/` — 门禁审批台账

| 文件 | 说明 |
|---|---|
| `README.md` | 台账用法说明 |
| `ledger.jsonl` | 追加式审批账本（首次记账时生成）。每行一个 JSON 记录，跨 intent/spec/plan/review/release/triage 各门禁；`git commit` 入库即审批留痕 |

### `evals/` — 回归评估套件（Phase 4）

| 文件 | 说明 |
|---|---|
| `README.md` | eval 的格式与运行方式 |
| `example.md` | eval 的 Markdown 参考写法 |
| `example.json` | eval 的标准 JSON 格式（`run_evals.py` 消费此格式） |

每起生产事故都应沉淀为一个新 eval 加入本目录，成为永久回归用例。

## workflow-graph.yaml 说明

`workflow-graph.yaml` 位于项目根目录（不在 iterations/ 内），是回路的**活状态机**：
描述六个节点、每个节点所处阶段、产出工件、把守门禁与当前状态，以及节点间由什么事件触发流转。
自动化可以执行边，但永远不能跳过门禁。

### 节点字段

| 字段 | 含义 |
|---|---|
| `stage` | 该节点所属的 SDLC 阶段（plan/design/build/deploy/maintain） |
| `artifact` | 节点产出的工件（文件路径或散文描述，如 `code + tests`） |
| `gate` | 通过该节点所需的人类门禁（须与台账记录的 gate 名一致） |
| `status` | 当前状态：`not_started`/`in_progress`/`accepted`/`approved`/`in_review`/`merged`/`pending`/`done` |
| `done_status` | 过门禁后节点落到的完成态 |

### 六个节点

| 节点 | stage | 工件 | 门禁 | 完成态 |
|---|---|---|---|---|
| intent | plan | `iterations/current/intent.md` | product_owner_accept | accepted |
| spec | design | `iterations/current/spec.md` | product_owner_approve | approved |
| plan | build | `iterations/current/plan.md` | engineer_approve | approved |
| implementation | build | code + tests | code_owner_approve | merged |
| release | deploy | authorized release | release_authorization | done |
| diagnosis | maintain | 新的 `iterations/current/intent.md` | on_call_triage | done |

注意命名规则：**节点名是它产出的工件**，`stage` 才是阶段——intent 节点
（stage: plan）的完成态是 `accepted`，plan 节点（stage: build）的完成态是 `approved`。

### 边（触发器）

```
intent --acceptance--> spec --approval--> plan --plan_accepted--> implementation
      --pr_merged--> release --band_breach_or_incident--> diagnosis --written_back--> intent
```

诊断（diagnosis）到意图（intent）的边是回路闭环：生产异常经分诊后写成新的
`iterations/current/intent.md`，重新进入 Plan 阶段。

### 日常操作

```bash
# 看当前回路状态（含状态与台账的漂移告警）
python3 iterations/scripts/workflow_state.py status

# 过门禁：一步完成台账记录 + 节点推进
python3 iterations/scripts/workflow_state.py close --node plan \
  --approver <who> --evidence <ticket>

# 校验图/账一致性（CI 或提交前）
python3 iterations/scripts/workflow_state.py check --strict
```

修改本文件时保持 JSON/YAML 可解析，节点 `gate` 名与台账记录一致；
文件顶部注释中的状态词汇表是唯一合法取值。
