# 三层 Harness 套件：团队安装与使用指南

> 版本：1.0 | 更新日期：2026-04-10
>
> 融合 Superpowers（执行纪律）+ OpenSpec（规范驱动）+ Compound Engineering 精选能力（多维评审 + 知识沉淀），
> 构建 Claude Code 最佳实践 harness。

---

## 目录

- [一、什么是 Harness？为什么需要它？](#一什么是-harness为什么需要它)
- [二、架构概览](#二架构概览)
- [三、安装指南（约 15 分钟）](#三安装指南约-15-分钟)
- [四、项目初始化](#四项目初始化)
- [五、完整工作流教程](#五完整工作流教程)
- [六、不同场景的简化用法](#六不同场景的简化用法)
- [七、关键人工介入点](#七关键人工介入点)
- [八、Skill 速查表](#八skill-速查表)
- [九、常见问题 FAQ](#九常见问题-faq)
- [十、维护与更新](#十维护与更新)
- [附录 A：完整文件清单与内容](#附录-a完整文件清单与内容)

---

## 一、什么是 Harness？为什么需要它？

Harness（驾驭框架）是围绕 AI 模型搭建的编排结构。没有 harness 时，AI 倾向于：跳过需求分析直接写代码、不写测试、自我评估虚高、长任务中丢失连贯性。

Anthropic 的研究表明：同一个模型在不同 harness 下的表现差距，有时大于不同模型之间的差距。

本套件解决三个核心问题：

| 问题 | 对应层 | 工具 |
|:-----|:-------|:-----|
| AI 不做需求分析就动手 | Layer 1 规范层 | Superpowers brainstorming + OpenSpec |
| AI 写的代码质量不可控 | Layer 2 执行层 | Superpowers TDD + 子 agent 隔离 + 微审查 |
| 经验不积累，每次从零开始 | Layer 3 质量知识层 | multi-review 宏审查 + compound-knowledge 知识沉淀 |

---

## 二、架构概览

```
用户说"做新功能"
    │
    ▼
┌─────────────────────────────────────────────┐
│  Layer 1：需求 & 规范                         │
│  Superpowers brainstorming（设计探索）          │
│       ↓                                       │
│  OpenSpec propose（生成结构化规范）              │
│       ↓                                       │
│  用户审阅规范 ✅                                │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  Layer 2：执行                                │
│  Superpowers writing-plans（战术分解）          │
│       ↓                                       │
│  Superpowers SDD（子 agent 执行）              │
│  ├── TDD: RED → GREEN → REFACTOR              │
│  ├── 子 agent 隔离（干净上下文）                │
│  └── 双阶段微审查（规格 + 质量）                │
└──────────────────┬──────────────────────────┘
                   ▼
┌─────────────────────────────────────────────┐
│  Layer 3：质量 & 知识                         │
│  /multi-review（多维宏审查）                    │
│  ├── 2-6 个 reviewer 子 agent 并行             │
│  ├── 信心度门控 + 指纹去重                      │
│  └── P0-P3 分级报告                            │
│       ↓                                       │
│  openspec archive（归档规范）                   │
│       ↓                                       │
│  /compound-knowledge（知识沉淀）                │
└─────────────────────────────────────────────┘
```

---

## 三、安装指南（约 5 分钟）

### 前提条件

- Claude Code CLI 已安装（[下载地址](https://claude.ai/download)）
- Node.js >= 18
- Git

### 一键安装

```bash
# 1. 获取安装脚本（从团队共享目录或内部仓库获取 install-harness.sh）

# 2. 运行安装脚本
chmod +x install-harness.sh
./install-harness.sh
```

脚本会自动完成以下所有步骤：

| 步骤 | 内容 | 说明 |
|:-----|:-----|:-----|
| 1 | 安装 OpenSpec CLI | `npm install -g @fission-ai/openspec@latest` |
| 2 | 创建目录结构 | `~/.claude/skills/multi-review/references/` 等 |
| 3 | 写入全局 CLAUDE.md | 三层协奏规则 + 工作流覆盖 + Skill 消歧 |
| 4 | 创建 multi-review skill | SKILL.md + 6 个 reviewer 参考文件 |
| 5 | 创建 compound-knowledge skill | 知识沉淀 skill |
| 6 | 初始化 OpenSpec 全局 skill | 4 个核心 workflow + 修补衔接指令 |

### 手动完成：安装 Superpowers 插件

脚本无法自动安装 Claude Code 插件，需要手动在 Claude Code 中运行：

```
/plugin install superpowers@claude-plugins-official
```

### 验证安装

在 Claude Code 中运行 `/skills`，确认看到以下关键 skill：

```
User skills:
  multi-review               ← 多维评审（脚本安装）
  compound-knowledge         ← 知识沉淀（脚本安装）
  openspec-propose           ← 规范提案（脚本安装）
  openspec-explore           ← 技术调研（脚本安装）
  openspec-apply-change
  openspec-archive-change

Plugin skills:
  superpowers:brainstorming  ← 设计探索（手动安装）
  superpowers:writing-plans
  superpowers:subagent-driven-development
  superpowers:test-driven-development
  superpowers:systematic-debugging
  superpowers:requesting-code-review
  ... (14 total)
```

### 可选配置

**简体中文输出**：脚本默认启用。如不需要，编辑 `~/.claude/CLAUDE.md`，删除 "Language Rule" 段落。

**强制 Opus 模型**：如需所有子 agent 使用 Opus（质量最高但成本较高），创建 `~/.claude/rules/model-selection.md`：

```markdown
# Sub-Agent Model Selection Rule

When dispatching ANY subagent via the Agent tool, you MUST set `model: "opus"`.
This applies to ALL subagent types without exception.
Do NOT downgrade to sonnet or haiku based on task complexity. Always use opus.
```

### 安装脚本做了什么（技术细节）

脚本创建的完整文件结构：

```
~/.claude/
├── CLAUDE.md                                    ← 全局三层协奏规则
├── skills/
│   ├── multi-review/
│   │   ├── SKILL.md                             ← 多维评审编排（6 阶段流水线）
│   │   └── references/
│   │       ├── correctness-reviewer.md          ← 逻辑/边界/竞态（始终参加）
│   │       ├── testing-reviewer.md              ← 覆盖率/断言/脆弱测试（始终参加）
│   │       ├── security-reviewer.md             ← 注入/认证/泄露（条件触发）
│   │       ├── performance-reviewer.md          ← N+1/内存/阻塞I/O（条件触发）
│   │       ├── adversarial-reviewer.md          ← 混沌工程式攻击验证（条件触发）
│   │       └── architecture-strategist.md       ← SOLID/耦合/分层（条件触发）
│   ├── compound-knowledge/
│   │   └── SKILL.md                             ← 知识沉淀（单 pass 提取+分类+写入）
│   ├── openspec-propose/
│   │   └── SKILL.md                             ← 衔接指令已修补（→ Superpowers）
│   ├── openspec-explore/
│   ├── openspec-apply-change/
│   └── openspec-archive-change/
└── commands/
    └── opsx/                                    ← OpenSpec 斜杠命令
```

6 个 reviewer 参考文件提取自 [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) 的 `plugins/compound-engineering/agents/review/`，每个是一个自包含的 reviewer 人格定义，包含：专注领域、信心度校准、不标记事项、JSON 输出格式。

---

## 四、项目初始化

每个新项目只需执行一次：

```bash
# 1. 进入项目目录
cd ~/projects/your-project

# 2. 初始化 OpenSpec
openspec init --tools claude

# 3. 创建知识目录
mkdir -p knowledge/subsystem-specs
touch knowledge/patterns.md knowledge/anti-patterns.md knowledge/decisions.md

# 4. 创建项目级 CLAUDE.md
cat > CLAUDE.md << 'EOF'
# Project Name

## Tech Stack
- (填写技术栈)

## Project Conventions
- (填写项目约定)

## Project Knowledge
knowledge/ 目录包含本项目积累的模式、反模式、决策记录和子系统知识。
开始工作前请先阅读相关知识文件。
EOF

# 5. 提交
git add -A && git commit -m "chore: initialize project with OpenSpec and knowledge directory"
```

初始化后的项目结构：

```
your-project/
├── CLAUDE.md                  ← 项目级配置
├── knowledge/                 ← 知识积累（提交到 git，团队共享）
│   ├── patterns.md
│   ├── anti-patterns.md
│   ├── decisions.md
│   └── subsystem-specs/
├── openspec/                  ← 规范管理（提交到 git，团队共享）
│   ├── changes/
│   │   └── archive/
│   ├── specs/
│   └── config.yaml
└── .claude/
    └── commands/opsx/         ← OpenSpec 斜杠命令
```

---

## 五、完整工作流教程

以"给项目添加用户通知系统"为例。

### Phase 1：设计探索

对 Claude 说：

```
我要给这个应用添加一个用户通知系统，支持邮件和站内通知。
```

**Superpowers brainstorming 自动触发**，进入苏格拉底式对话——一次问一个问题，帮你发现还没想到的细节。回答每个问题即可。

### Phase 2：规范生成

brainstorming 完成后，对 Claude 说：

```
先运行 openspec propose 来正式化这个设计。
```

> 为什么需要手动说这句？因为 brainstorming 的默认终态是直接跳到 writing-plans。
> 虽然 CLAUDE.md 有覆盖规则，但 brainstorming 的优先级极高，有时会忽略。
> 这是目前唯一需要人工干预的衔接点。

Claude 运行 `openspec propose`，生成：
- `proposal.md` — 提案（为什么做、做什么）
- `design.md` — 技术设计（怎么做）
- `specs/` — 行为规范（每个能力的需求 + 验收场景）
- `tasks.md` — 功能级任务清单

### Phase 3：审阅规范

**这是你最重要的审阅环节。** 打开生成的文件：

- 检查 proposal.md 是否准确描述了你的意图
- 检查 specs/ 中每个规范的需求和场景是否完整
- 检查 tasks.md 的任务分解是否合理

如需修改，直接告诉 Claude：

```
tasks.md 需要加一个任务：实现通知频率限制。
```

审阅通过后说：

```
规范审核通过，开始实现。
```

### Phase 4：执行实现

Claude 自动进入 Superpowers 工作流：

1. 读取 tasks.md 中的功能级任务
2. 对每个任务用 **writing-plans** 细化为 2-5 分钟的战术步骤
3. 用 **subagent-driven-development** 执行：
   - 每个步骤派出独立子 agent（干净上下文）
   - 强制 TDD（先写测试、看它失败、再写代码）
   - 双阶段微审查（规格合规 → 代码质量）

你大部分时间可以观察。需要介入的情况：
- Claude 需要你做技术决策
- 某步骤审查失败两次
- 发现实现偏离规范

### Phase 5：全面评审

所有功能实现后说：

```
做一次全面评审。
```

**/multi-review 触发**，动态选择 reviewer 子 agent 并行评审：

```
Review team (5 reviewers):
- correctness (always)
- testing (always)
- security -- 涉及用户数据
- performance -- 有数据库查询
- architecture -- 新增模块
```

输出结构化报告，按 P0-P3 分级。修复必要问题后继续。

### Phase 6：归档 & 知识沉淀

```
归档并沉淀知识。
```

Claude 执行：
1. `openspec archive` — 合并规范到主 specs，归档变更
2. `/compound-knowledge` — 提取经验写入 knowledge/ 目录

---

## 六、不同场景的简化用法

| 场景 | 怎么做 | 跳过什么 |
|:-----|:-------|:---------|
| **Bug 修复** (< 15 min) | 直接描述 bug，Claude 进入 systematic-debugging + TDD | 跳过 Layer 1，有经验就说"沉淀一下" |
| **小功能** (< 1 小时) | `/opsx:propose 添加XX功能`，跳过 brainstorming | 跳过 brainstorming，正常走 Layer 2+3 |
| **中等功能** (1-3 小时) | 简短 brainstorming 后走完整流程 | 可简化 brainstorming |
| **大型重构** (> 4 小时) | **完整三层**，每个模块单独审查 | 不跳过任何步骤 |
| **技术调研** | `/opsx:explore 分析XX方案的利弊` | 不产出正式规范 |
| **跳过所有流程** | `直接修改XX文件，不走流程` | 全跳过，harness 是工具不是枷锁 |

---

## 七、关键人工介入点

| 时机 | 你做什么 | 为什么 |
|:-----|:---------|:-------|
| brainstorming 结束时 | 说"先 openspec propose" | brainstorming 默认直跳 writing-plans |
| OpenSpec 规范生成后 | 逐文件审阅 | 规范错误会级联到所有下游工作 |
| SDD 执行中遇阻塞 | 帮做架构决策 | 子 agent 没有足够上下文做战略决策 |
| multi-review 报告后 | 判断 P2/P3 是否值得修 | 不是所有发现都需要修 |
| compound-knowledge 时 | 确认经验是否准确 | 错误的知识比没有知识更危险 |

> 其中只有**第一个**（brainstorming 结束时）是工具限制导致的必要干预，
> 其余都是好的工程实践——人类应该审阅规范、做架构决策、判断优先级。

---

## 八、Skill 速查表

### 自动触发的 Skill（不需要手动调用）

| Skill | 触发条件 |
|:------|:---------|
| superpowers:brainstorming | 说"做新功能"、"添加XX"等创建性工作 |
| superpowers:test-driven-development | 在 SDD 执行中自动强制 |
| superpowers:requesting-code-review | SDD 每个任务完成后自动触发 |
| superpowers:systematic-debugging | 遇到 bug 或测试失败时 |
| superpowers:verification-before-completion | 声称工作完成前自动触发 |

### 手动触发的 Skill / 命令

| 触发词 | 做什么 |
|:-------|:-------|
| `先 openspec propose` | brainstorming 后过渡到 OpenSpec |
| `规范审核通过，开始实现` | 触发 Superpowers Layer 2 执行流程 |
| `做一次全面评审` / `multi-review` | 触发多维宏审查 |
| `沉淀知识` / `compound` | 触发知识沉淀 |
| `归档` | 触发 openspec archive |
| `/opsx:explore XXX` | 技术调研模式 |
| `/opsx:propose XXX` | 直接生成规范（跳过 brainstorming） |

---

## 九、常见问题 FAQ

### Q: brainstorming 太冗长，小功能不想走

直接说 `/opsx:propose 添加XX功能`，跳过 brainstorming。

### Q: Claude 在 brainstorming 后直接跳到 writing-plans 了

说"等一下，先运行 openspec propose"。这是目前无法完全自动化的唯一衔接点。

### Q: OpenSpec 生成的规范质量不好

在 `openspec/config.yaml` 中添加项目上下文：

```yaml
context: |
  Tech stack: TypeScript, React 19, Node.js, PostgreSQL
  Architecture: Monorepo with apps/ and packages/
  Testing: Vitest for unit, Playwright for E2E
```

### Q: multi-review 报告中某个 reviewer 没有触发

reviewer 是根据 diff 内容动态选择的。如果你认为应该触发某个 reviewer，可以说"再用 security-reviewer 检查一下"。

### Q: 多个功能并行开发

用 Superpowers 的 git worktree：

```
用 git worktree 创建一个隔离的工作空间来做通知系统
```

### Q: `openspec update` 后 propose skill 的修改被覆盖了

重新运行 `./install-harness.sh`，Step 6 会自动修补衔接指令。

### Q: 团队怎么共享知识？

- `openspec/` 和 `knowledge/` 目录提交到 git → 团队自动共享
- `~/.claude/` 是个人全局配置 → 每人按本文档自行安装

### Q: 能关闭简体中文输出吗？

删除 `~/.claude/CLAUDE.md` 中的 "Language Rule" 段落。

### Q: Token 消耗大约多少？

- Skill 描述注册：约 900 tokens（固定开销，占 200K 窗口的 0.45%）
- 完整三层流程一次：取决于项目大小，通常 50K-200K tokens
- 如果配置了 model-selection.md 强制 opus：所有子 agent 用 opus，成本较高

---

## 十、维护与更新

### Superpowers 插件更新

Claude Code 会自动检查插件更新，无需手动操作。

### OpenSpec CLI 更新

```bash
npm update -g @fission-ai/openspec
```

**更新后必须：** 重新运行 `./install-harness.sh`，脚本会自动修补 openspec-propose 的衔接指令。

### multi-review / compound-knowledge 更新

这些是你自己的全局 skill 文件，不会被任何工具覆盖。如需更新 reviewer 定义，从 [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) 的最新版本重新提取。

---

## 快速开始 Checklist

- [ ] 获取 `install-harness.sh` 安装脚本
- [ ] 确认已安装 Claude Code CLI、Node.js >= 18、Git
- [ ] 运行 `chmod +x install-harness.sh && ./install-harness.sh`
- [ ] 在 Claude Code 中运行 `/plugin install superpowers@claude-plugins-official`
- [ ] 运行 `/skills` 验证（应看到 multi-review、compound-knowledge、openspec-* 和 superpowers:*）
- [ ] （可选）创建 `~/.claude/rules/model-selection.md` 强制 Opus
- [ ] （可选）编辑 `~/.claude/CLAUDE.md` 删除 Language Rule（如不需要简体中文）
- [ ] 在新项目中运行 `openspec init --tools claude` + 创建 `knowledge/` 目录
- [ ] 试跑一次完整流程
