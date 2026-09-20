# AI-Native SDLC — 可复用工作流仓库

> [![skills.sh](https://skills.sh/b/BouBoo-Min/ai-sdlc)](https://skills.sh/BouBoo-Min/ai-sdlc)
>
> English | [简体中文](README.zh-CN.md)

一个开箱即用的 Anthropic [AI-Native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) 实现（另见参考实现 [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc)）：给你的编码 agent 一个目标或想法，它就会搭建骨架并驱动项目走完整生命周期——**Plan → Design → Build → Test → Deploy → Maintain**——每一次交接都有人工审批门禁。

本仓库是一个位于 `skills/ai-sdlc/` 的 **skill**，可安装到 `~/.codex/skills`（Codex）或 `~/.claude/skills`（Claude Code）；同时也是打包该 skill 的 **Codex 插件**（仓库根目录的 `.codex-plugin/plugin.json`）。

## 这是在解决什么问题

写代码不再是瓶颈——agent 几小时就能产出代码。瓶颈转移到了代码周边的流程：规划、评审、部署和治理仍以人类速度和规模运转。本仓库重构 SDLC，让这些环节跟上构建速度：

- 循环为 **Plan → Design → Build → Test → Deploy → Maintain**；每个阶段以提交一个版本化工件结束，下一阶段从读取它开始。
- 人类判断集中在**门禁**，而不是逐行评审。
- 护栏以**确定性 hook** 运行，而不是靠习惯。
- 持续 **eval** 取代阶段门 QA。

一句话原则：**agent 可以做到生产门禁之前的一切，但绝不跨越它。**

## 工作流

```
Plan → Design → Build → Test → Deploy → Maintain
  ↑                                             │
  └───────────────── 回到 Plan ←───────────────┘
```

| 阶段 | 读取 | 产出 | 门禁（人工审批） |
|---|---|---|---|
| Plan | 用户想法 | `iterations/current/intent.md` | 接受 → Design |
| Design | intent + 规范 | `iterations/current/spec.md` | 批准 → Build |
| Build | intent + spec | `plan.md` → 代码 + 测试 → PR | 计划批准；PR 合并 → Deploy |
| Test | 仓库 + eval 套件 | eval 结果、回归用例 | 降低通过率的配置变更需评审 |
| Deploy | 已合并 PR | 经授权的发布 | 显式发布授权 |
| Maintain | 生产指标 | 诊断 → 新的 `intent.md` | 值班分诊 |

阶段 → 工件 → 门禁 的完整契约见 [`skills/ai-sdlc/SKILL.md`](skills/ai-sdlc/SKILL.md)（唯一权威来源）。机器可读的图状态是 `workflow-graph.yaml`——骨架中唯一留在项目根目录的文件；其余全部位于 `iterations/` 下（包括 `REVIEW.md`、`bands.yaml` 和可选的 agent 组织）。

## 安装

### 通过 skills.sh 安装（推荐，支持 Claude Code、Codex、Cursor、OpenCode 等 75+ 个 Agent）

```bash
npx skills add BouBoo-Min/ai-sdlc
```

只安装到指定 Agent：

```bash
npx skills add BouBoo-Min/ai-sdlc --skill ai-sdlc -a claude-code   # Claude Code
npx skills add BouBoo-Min/ai-sdlc --skill ai-sdlc -a codex         # Codex
```

加 `-g` 表示全局安装（对所有项目可用），不加则安装到当前项目。技能页面：[skills.sh/BouBoo-Min/ai-sdlc](https://skills.sh/BouBoo-Min/ai-sdlc)。

### 作为 Codex skill

```bash
mkdir -p ~/.codex/skills
cp -R skills/ai-sdlc ~/.codex/skills/
```

### 作为 Claude Code skill

```bash
mkdir -p ~/.claude/skills
cp -R skills/ai-sdlc ~/.claude/skills/
```

### 作为 Codex 插件

克隆或复制本仓库，然后把它加入 `~/.agents/plugins/marketplace.json`：

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

安装插件即包含捆绑的 skill——二选一，不必同时装。

## 使用

新建项目：

```bash
python3 skills/ai-sdlc/scripts/init_workflow.py my-project --name "我的想法"
```

然后对 agent 说：

> $ai-sdlc：我想做一个报销跟踪器，从 intent 开始。

agent 会用分析师式的问题把想法问具体，写 `iterations/current/intent.md` 并提交，请你接受。随后依次经过 spec → plan → build → test → deploy，在每个审批门禁停下，最后接好监控，让循环能闭环回新的 intent。

已有项目？直接在项目内搭骨架：

```bash
python3 skills/ai-sdlc/scripts/init_workflow.py .
```

骨架不会创建 `CLAUDE.md`/`AGENTS.md` 或 `.gitignore`——请维护你自己的仓库记忆文件和忽略规则。

## 自治 agent 组织

团队若想让循环少一些人工干预，skill 可以往任意项目里搭建 **agent 组织**：有名有姓的角色、组织架构、每份工件的同行评审、多渠道需求摄入：

```bash
python3 skills/ai-sdlc/scripts/init_org.py my-project
```

默认组织：**CEO（你，人类）** → **CTO（agent）** → 产品经理、产品工程 agent、工程师、评审者。agent 跑各阶段、互相评审，只在关键门禁（意图歧义、spec/plan 分歧未决、PR 合并、发布）上报人类 CEO。所有内容落在 `my-project/iterations/org/` 下。

完整协议见 [`skills/ai-sdlc/references/org.md`](skills/ai-sdlc/references/org.md)。

## 为你的组织定制

- **规范即 skill** — 把品牌、安全、UX、合规政策写成 skill，让 Design 和 Build 一致地应用它们。
- **Hook 即红线** — 受保护路径、密钥、发布门禁放进确定性 hook，而不是散文。`production-gate.sh` 在无人工授权时拦截部署（测试套件是 `tests/test_gate.sh`）；`hook-settings.example.json` 是接线示例。
- **Eval** — 收集真实任务与预期结果；每次配置变更后和每次事故后在 CI 运行（`agent-evals.yml.example`）。
- **评审文化** — `iterations/REVIEW.md` 定义 AI PR 评审循环的软规则：三轮 pass（bug、安全、合规）、证据要求、5 条 nit 上限。
- **监控分级** — `iterations/bands.yaml` 定义 1σ/2σ/3σ 响应；3σ 时 agent 只能通过开 PR 进入评审门禁，或触发预批准 runbook。

## 许可证

MIT — 见 [LICENSE](LICENSE)。本项目衍生自 [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc)（MIT）。

## 开发

校验整个 bundle（frontmatter、链接、插件清单、YAML/JSON、shell 语法、门禁测试、脚手架冒烟测试）：

```bash
python3 skills/ai-sdlc/scripts/quick_validate.py
```

## 参考资料

- [The AI-Native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) — 本工作流实现的 Anthropic 博客原文。
- [bashebr/ai-native-sdlc](https://github.com/bashebr/ai-native-sdlc) — 本项目是它的**衍生作品**，依据 MIT 许可证在其基础上改编；结构、脚本与模板均源自该项目。
