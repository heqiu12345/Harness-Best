#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 三层 Harness 一键安装脚本 v2
# Superpowers + OpenSpec + Multi-Review + Compound-Knowledge
# + Tech-Proposal + Stop Hook + 禁止规则
# ============================================================

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!!]${NC} $1"; }
error() { echo -e "${RED}[ERR]${NC} $1"; }

echo ""
echo "=========================================="
echo "  三层 Harness 套件安装程序 v2"
echo "  Superpowers + OpenSpec + CE 精选能力"
echo "  + 禁止规则 + Knowledge Index + Stop Hook"
echo "=========================================="
echo ""

# ─── 前置检查 ─────────────────────────────────

MISSING=0
command -v claude &>/dev/null || { error "Claude Code CLI 未安装 (https://claude.ai/download)"; MISSING=1; }
command -v node   &>/dev/null || { error "Node.js 未安装 (需要 >= 18)"; MISSING=1; }
command -v git    &>/dev/null || { error "Git 未安装"; MISSING=1; }
[ "$MISSING" -eq 1 ] && exit 1
info "前置检查通过"

# ─── Step 1: OpenSpec CLI ─────────────────────

echo ""
echo "--- Step 1/8: OpenSpec CLI ---"
if command -v openspec &>/dev/null; then
  info "OpenSpec CLI 已安装 (v$(openspec -V 2>/dev/null || echo '?'))"
else
  warn "正在安装 OpenSpec CLI..."
  npm install -g @fission-ai/openspec@latest
  info "OpenSpec CLI 安装完成"
fi

# ─── Step 2: 目录结构 ─────────────────────────

echo ""
echo "--- Step 2/8: 目录结构 ---"
mkdir -p "$SKILLS_DIR/multi-review/references"
mkdir -p "$SKILLS_DIR/compound-knowledge"
mkdir -p "$SKILLS_DIR/tech-proposal"
mkdir -p "$SCRIPTS_DIR"
info "目录结构创建完成"

# ─── Step 3: 全局 CLAUDE.md ───────────────────

echo ""
echo "--- Step 3/8: 全局 CLAUDE.md ---"
[ -f "$CLAUDE_DIR/CLAUDE.md" ] && { warn "CLAUDE.md 已存在，备份为 CLAUDE.md.bak"; cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"; }

cat > "$CLAUDE_DIR/CLAUDE.md" << 'CLAUDE_EOF'
# Global Harness Configuration

## Language Rule

All output MUST be in Simplified Chinese (简体中文). This includes: conversations, explanations, commit messages, PR descriptions, code review reports, knowledge documentation, OpenSpec artifacts (proposal/design/specs/tasks), and any other generated text. The only exceptions are code identifiers, CLI commands, and file paths which remain in English. This rule applies unconditionally across all skills and workflows.

---

Three-layer harness architecture: Superpowers (execution discipline) + OpenSpec (spec-driven development) + multi-review/compound-knowledge (quality & knowledge).

## Workflow Overrides (take precedence over individual skill instructions)

### After brainstorming completes:
Brainstorming says "invoke writing-plans" as its terminal state. In this project, insert one step before writing-plans: run `openspec propose "<description>"` to formalize the design into versioned specs. Then use writing-plans to decompose each task from the generated tasks.md. The sequence is: brainstorming → `openspec propose` → writing-plans → SDD. Never skip the openspec propose step.

### After openspec propose completes:
Do NOT use /opsx:apply. Instead, read the generated tasks.md and use Superpowers writing-plans to decompose each feature-level task into tactical 2-5 minute steps, then subagent-driven-development to execute. The sequence is: openspec propose → writing-plans → SDD. Never use /opsx:apply.

## Absolute Prohibitions

These rules override all other instructions. No exceptions, no "just this once."

- 禁止在 brainstorming 完成后直接跳到 writing-plans——必须先运行 `openspec propose`
- 禁止使用 /opsx:apply 执行任务——必须通过 Superpowers writing-plans → SDD
- 禁止未经 writing-plans 细化就直接执行 tasks.md 中的功能级任务
- 禁止功能模块完成后未运行 /multi-review 就声称开发完成或创建 PR
- 禁止重大功能结束后未提供 /compound-knowledge 就结束会话——至少询问用户是否需要沉淀知识
- 禁止未读取 knowledge/index.md 就开始实现工作（文件不存在时跳过，不报错）
- 禁止全量加载 knowledge/ 下所有文件——只读 index.md，根据当前任务相关性按需读取具体文件

## Skill Disambiguation

- **Code review**: Superpowers' requesting-code-review is the per-task micro-review inside SDD (runs automatically, do not invoke manually). /multi-review is the cross-cutting macro-review after a feature module is complete (invoke explicitly).
- **Exploration**: openspec-explore is for investigating within an active OpenSpec change. Superpowers brainstorming is for initial feature design before any change exists.
- **Skill creation**: skill-creator is for eval-driven skill iteration with benchmarking. superpowers:writing-skills is for quick skill creation following Superpowers conventions.

## Three-Layer Workflow

### Layer 1: Requirements & Specification (Superpowers brainstorming + OpenSpec)

When starting new feature work:
1. Superpowers brainstorming activates naturally -- follow its design exploration process
2. **After the design is agreed upon, DO NOT go directly to writing-plans.** Instead, transition to OpenSpec: run `openspec propose "<feature description>"` via bash to generate structured specs (proposal.md + specs/ + design.md + tasks.md)
3. (Optional) If cross-team review is needed, run /tech-proposal to generate a team-reviewable technical design document. Skip this step for solo work or changes that don't require cross-team alignment.
4. The user reviews and approves the spec before any code is written
5. The openspec/changes/ directory is the single source of truth for requirements

Key: brainstorming produces design consensus, OpenSpec formalizes it into versioned specs. tech-proposal is optional — use it when the change needs cross-team alignment.

### Layer 2: Execution (Superpowers)

When implementing approved specs:
1. Read the tasks from openspec/changes/<change-name>/tasks.md -- these are strategic, feature-level tasks
2. For each feature-level task, use Superpowers writing-plans to decompose it into tactical 2-5 minute implementation steps with exact file paths, complete code blocks, and test commands
3. Use Superpowers subagent-driven-development to execute each tactical plan -- this provides TDD enforcement, sub-agent isolation, and per-task micro-review automatically
4. Superpowers' internal skill chain (TDD -> code review -> git) runs automatically within each task

Key: OpenSpec does strategic decomposition (what features to build), Superpowers does tactical decomposition (how to build each feature). Both layers are needed.

### Layer 3: Quality & Knowledge (multi-review + compound-knowledge)

After completing a feature module:
1. Run /multi-review for comprehensive multi-persona code review -- this dispatches parallel sub-agent reviewers (correctness, security, performance, etc.) selected dynamically based on what changed
2. Fix any P0/P1 findings before proceeding
3. After the feature is fully complete, run `openspec archive` to merge specs
4. Run /compound-knowledge to document valuable learnings from this work

Key: Superpowers' per-task micro-review catches implementation errors; multi-review catches architectural and cross-cutting issues. compound-knowledge ensures learnings persist across sessions.

## Project Knowledge

Each project should have a `knowledge/` directory with an `index.md` index file. Structure:

```
knowledge/
├── index.md              ← 始终读取（一行摘要索引）
├── patterns/             ← 按需读取
├── anti-patterns/        ← 按需读取
├── decisions/            ← 按需读取
└── subsystem-specs/      ← 按需读取
```

When starting work in a project:
- Read knowledge/index.md (NOT the entire directory)
- Based on current task relevance, read specific knowledge files on demand
- After significant work, use /compound-knowledge to add new learnings

## Quick Reference

| Phase | Tool | Trigger |
|-------|------|---------|
| Design exploration | Superpowers brainstorming | Automatic on new feature work |
| Spec formalization | OpenSpec CLI (`openspec propose`) | After design consensus |
| Tech proposal (optional) | /tech-proposal | After propose, when cross-team review needed |
| Tactical planning | Superpowers writing-plans | Per feature-level task |
| Implementation | Superpowers SDD | Per tactical plan |
| Macro review | /multi-review | After feature module complete |
| Spec archive | `openspec archive` | After all tasks done |
| Knowledge capture | /compound-knowledge | After significant work |
CLAUDE_EOF
info "全局 CLAUDE.md 创建完成"

# ─── Step 4: multi-review skill + reviewers ───

echo ""
echo "--- Step 4/8: multi-review skill ---"

cat > "$SKILLS_DIR/multi-review/SKILL.md" << 'SKILL_EOF'
---
name: multi-review
description: "Multi-persona code review using parallel sub-agents with dynamic reviewer selection, confidence gating, and finding deduplication. Use when completing a feature module, before creating a PR, or when requesting a comprehensive code review."
---

# Multi-Persona Code Review

Reviews code changes by dispatching parallel sub-agent reviewers, each with a distinct expertise. Merges and deduplicates findings into a single actionable report.

## When to Use

- After completing a feature module or significant code change
- Before creating a PR
- When asked for a "full review", "comprehensive review", or "multi-review"
- After Superpowers' per-task micro-reviews, as a broader "macro-review"

## Stage 1: Determine Scope

```bash
BASE=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo "HEAD~10") && echo "BASE:$BASE" && echo "FILES:" && git diff --name-only $BASE && echo "DIFF:" && git diff -U10 $BASE
```

## Stage 2: Intent Discovery

Write a 2-3 line intent summary from branch name, commit messages, and conversation context.

## Stage 3: Select Reviewers

**Always-on:** correctness-reviewer, testing-reviewer

**Conditional:**

| Reviewer | Select when diff touches... |
|----------|---------------------------|
| security-reviewer | Auth, public endpoints, user input, permissions |
| performance-reviewer | DB queries, data transforms, caching, I/O-heavy paths |
| adversarial-reviewer | Diff >=50 changed lines, OR auth/payments/data mutations/external APIs |
| architecture-strategist | Structural refactors, new services, pattern changes |

Announce the team before spawning.

## Stage 4: Dispatch Sub-Agents

Spawn each selected reviewer as a **parallel sub-agent** using the Agent tool. Each receives the persona prompt from `references/<reviewer-name>.md`, the intent summary, file list, and diff.

## Stage 5: Merge Findings

1. **Validate** — drop malformed returns
2. **Confidence gate** — suppress below 0.60 (P0 at 0.50+ survives)
3. **Deduplicate** — fingerprint by `file + line_bucket(+/-3) + normalized_title`
4. **Cross-reviewer boost** — 2+ reviewers flag same issue → +0.10 confidence
5. **Sort** — severity (P0 first) → confidence desc → file path

## Stage 6: Present Report

Structured markdown report with findings table (P0-P3), details, residual risks, testing gaps, and verdict (Ready to merge / Ready with fixes / Not ready).

If any knowledge/ directory exists in the project, read knowledge/index.md before reviewing to use accumulated project knowledge as context.

## Quality Gates

1. Every finding must be actionable
2. Verify line numbers against actual file content
3. Severity calibration — style nits never P0, SQL injection never P3
4. No false positives from skimming

## Fallback

If the platform doesn't support parallel sub-agents, run reviewers sequentially.
SKILL_EOF

info "multi-review SKILL.md 创建完成"

# --- 6 Reviewer Reference Files ---

cat > "$SKILLS_DIR/multi-review/references/correctness-reviewer.md" << 'REF_EOF'
---
name: correctness-reviewer
description: Always-on code-review persona. Reviews code for logic errors, edge cases, state management bugs, error propagation failures, and intent-vs-implementation mismatches.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Correctness Reviewer

You are a logic and behavioral correctness expert who reads code by mentally executing it -- tracing inputs through branches, tracking state across calls, and asking "what happens when this value is X?"

## What you're hunting for
- **Off-by-one errors and boundary mistakes**
- **Null and undefined propagation**
- **Race conditions and ordering assumptions**
- **Incorrect state transitions**
- **Broken error propagation**

## Confidence calibration
- **High (0.80+)**: Full execution path traceable from input to bug
- **Moderate (0.60-0.79)**: Bug depends on conditions visible but not fully confirmable
- **Low (below 0.60)**: Requires runtime conditions with no evidence. Suppress.

## What you don't flag
- Style preferences, missing optimization, naming opinions, defensive coding for impossible nulls

## Output format
```json
{ "reviewer": "correctness", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/security-reviewer.md" << 'REF_EOF'
---
name: security-reviewer
description: Conditional code-review persona, selected when the diff touches auth middleware, public endpoints, user input handling, or permission checks.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Security Reviewer

You are an application security expert who thinks like an attacker.

## What you're hunting for
- **Injection vectors** (SQL, XSS, shell, template)
- **Auth and authz bypasses**
- **Secrets in code or logs**
- **Insecure deserialization**
- **SSRF and path traversal**

## Confidence calibration
Security findings have a **lower threshold** (0.60 is actionable).
- **High (0.80+)**: Full attack path traceable
- **Moderate (0.60-0.79)**: Pattern present, exploitability uncertain
- **Low (below 0.60)**: Suppress.

## What you don't flag
- Defense-in-depth on already-protected code, theoretical physical-access attacks, dev config HTTP, generic hardening advice

## Output format
```json
{ "reviewer": "security", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/performance-reviewer.md" << 'REF_EOF'
---
name: performance-reviewer
description: Conditional code-review persona, selected when the diff touches database queries, loop-heavy data transforms, caching layers, or I/O-intensive paths.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Performance Reviewer

You are a runtime performance and scalability expert.

## What you're hunting for
- **N+1 queries**
- **Unbounded memory growth**
- **Missing pagination**
- **Hot-path allocations**
- **Blocking I/O in async contexts**

## Confidence calibration
Performance findings have a **higher threshold**.
- **High (0.80+)**: Impact provable from code
- **Moderate (0.60-0.79)**: Pattern present, impact depends on unknown data size
- **Low (below 0.60)**: Suppress.

## What you don't flag
- Micro-optimizations in cold paths, premature caching suggestions, theoretical scale issues in MVP, style-based performance opinions

## Output format
```json
{ "reviewer": "performance", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/architecture-strategist.md" << 'REF_EOF'
---
name: architecture-strategist
description: Analyzes code changes from an architectural perspective for pattern compliance and design integrity.
model: inherit
---

# Architecture Strategist

You are a System Architecture Expert. Ensure modifications align with established architectural patterns, maintain system integrity, and follow best practices.

## Analysis approach
1. Understand system architecture (docs, README, code patterns)
2. Analyze change context (integration points, broader implications)
3. Identify violations (anti-patterns, coupling, cohesion)
4. Consider long-term implications (scalability, maintainability)

## Verify
- No new circular dependencies
- Component boundaries respected
- Appropriate abstraction levels
- API contracts stable or properly versioned
- Design patterns consistently applied

## Confidence calibration
- **High (0.80+)**: Violation directly visible in diff
- **Moderate (0.60-0.79)**: Depends on broader context
- **Low (below 0.60)**: Speculative. Suppress.

## What you don't flag
- Style preferences, premature abstraction on small code, technology choice debates

## Output format
```json
{ "reviewer": "architecture", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/adversarial-reviewer.md" << 'REF_EOF'
---
name: adversarial-reviewer
description: Conditional code-review persona, selected when the diff is large (>=50 changed lines) or touches high-risk domains. Constructs failure scenarios.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Adversarial Reviewer

You are a chaos engineer who reads code by trying to break it.

## Depth calibration
- **Quick** (< 50 lines, no risk): Assumption violation only, max 3 findings
- **Standard** (50-199 lines or minor risk): + composition failures + abuse cases
- **Deep** (200+ lines or auth/payments/data mutations): All four techniques + cascade construction

## What you're hunting for
1. **Assumption violation** — data shape, timing, ordering, value range
2. **Composition failures** — contract mismatches, shared state, ordering across boundaries
3. **Cascade construction** — resource exhaustion, state corruption, recovery-induced failures
4. **Abuse cases** — repetition, timing, concurrent mutation, boundary walking

## Confidence calibration
- **High (0.80+)**: Complete concrete scenario constructable
- **Moderate (0.60-0.79)**: One step depends on unconfirmable conditions
- **Low (below 0.60)**: Suppress.

## What you don't flag
- Individual logic bugs (correctness), known vulnerability patterns (security), performance anti-patterns (performance), test gaps (testing)

## Output format
```json
{ "reviewer": "adversarial", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/testing-reviewer.md" << 'REF_EOF'
---
name: testing-reviewer
description: Always-on code-review persona. Reviews code for test coverage gaps, weak assertions, brittle tests, and missing edge case coverage.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Testing Reviewer

You are a test architecture and coverage expert.

## What you're hunting for
- **Untested branches in new code**
- **Tests that don't assert behavior (false confidence)**
- **Brittle implementation-coupled tests**
- **Missing edge case coverage for error paths**
- **Behavioral changes with no test additions**

## Confidence calibration
- **High (0.80+)**: Gap provable from diff alone
- **Moderate (0.60-0.79)**: Inferring from file structure
- **Low (below 0.60)**: Suppress.

## What you don't flag
- Missing tests for trivial getters/setters, test style preferences, coverage percentage targets, missing tests for unchanged code

## Output format
```json
{ "reviewer": "testing", "findings": [], "residual_risks": [], "testing_gaps": [] }
```
REF_EOF

info "6 个 reviewer 参考文件创建完成"

# ─── Step 5: compound-knowledge skill ─────────

echo ""
echo "--- Step 5/8: compound-knowledge skill ---"

cat > "$SKILLS_DIR/compound-knowledge/SKILL.md" << 'SKILL_EOF'
---
name: compound-knowledge
description: "Document a recently solved problem or valuable discovery to compound project knowledge. Use after completing a significant feature, fixing a complex bug, making an architectural decision, or when valuable experience should be preserved for future reference."
---

# Compound Knowledge

Capture problem solutions and valuable discoveries while context is fresh, writing per-topic knowledge files with a lightweight index for future AI sessions.

**Why "compound"?** Each documented solution compounds your team's knowledge. The first time you solve a problem takes research. Document it, and the next occurrence takes minutes.

## When to Use

- After fixing a complex bug
- After completing a significant feature
- After making an important architectural decision
- When a discovery would save future time
- When explicitly asked to "sediment knowledge", "compound", or "document learnings"

## Knowledge Directory Structure

Knowledge is stored in the project's `knowledge/` directory (project-level, not global). Each entry is an **independent file**, organized by type. `index.md` is the lightweight index — the only file that should be loaded at session start.

```
knowledge/
├── index.md                          ← one-line summary per entry (< 500 tokens)
├── patterns/
│   ├── eager-loading-n-plus-one.md   ← one topic per file
│   └── bezier-smoothing.md
├── anti-patterns/
│   ├── force-clearing-order.md
│   └── canvas-css-background.md
├── decisions/
│   └── zero-dependency-single-file.md
└── subsystem-specs/
    └── notification-system.md
```

If the directory doesn't exist, create it on first use (including index.md and the category subdirectories).

## Execution (Single Pass)

### Step 1: Extract from Context
Review conversation history: what was solved, what was tried, what worked, what to prevent.

### Step 2: Classify and Name
Determine type (pattern / anti-pattern / decision / subsystem) and generate a kebab-case filename slug.

### Step 3: Write Knowledge File
Create an independent file at the classified path with: title, metadata (date, type, tags), context, discovery/solution, why it works, prevention/when to apply.

### Step 4: Update index.md
Append one line under the appropriate section: `- [Title](category/slug.md) — summary (< 80 chars)`. Create index.md with section headers if it doesn't exist.

Index rules:
- One entry per line, never multi-line
- Keep total index under 50 entries
- Summary must be meaningful enough for Claude to judge relevance without reading the full file

### Step 5: Check for Staleness
Scan index.md for entries the new knowledge might contradict. Update or remove stale entries.

### Step 6: CLAUDE.md Discoverability
Check if the project's CLAUDE.md mentions `knowledge/index.md`. If not, suggest adding a note.

## Rules

- Every entry must be specific and actionable — no vague "be careful with X"
- Include real code examples or commands when applicable
- One topic per file — do NOT append multiple entries to a single file
- Tag with date for future staleness assessment
- Keep index.md under 50 entries and under 500 tokens
SKILL_EOF

info "compound-knowledge SKILL.md 创建完成"

# ─── Step 6: tech-proposal skill ──────────────

echo ""
echo "--- Step 6/8: tech-proposal skill ---"

cat > "$SKILLS_DIR/tech-proposal/SKILL.md" << 'SKILL_EOF'
---
name: tech-proposal
description: "Generate a team-reviewable technical design document from OpenSpec artifacts. Use after openspec propose completes, before implementation, when a formal tech proposal is needed for cross-team review."
---

# Tech Proposal Generator

Read the current OpenSpec change artifacts (proposal.md, design.md, specs/, tasks.md) and generate a structured technical design document suitable for cross-team review.

## When to Use

- After `openspec propose` completes and before implementation begins
- When multiple teams/roles need to review and sign off
- Triggered by: "生成技术方案", "tech proposal", "生成评审文档"

## Output

Write to: `openspec/changes/<name>/tech-proposal.md`

## Document Structure

Adapt sections to the change — skip irrelevant sections, but never skip 1 (Background), 2 (Architecture), 8 (Risks), 9 (Open Questions).

1. Background & Goals (1.1 Background, 1.2 Goals, 1.3 Non-Goals, 1.4 Related Docs)
2. Architecture Overview (system diagram, component responsibilities, data flow)
3. Core Feature Design (per capability from specs/)
4. API Design (if applicable — full request/response/example for each endpoint)
5. Database Design (if applicable — columns, indexes, constraints, migration)
6. Cross-Team Impact Analysis (table: team, impact level, details, action required)
7. Migration & Rollout Strategy (if applicable)
8. Risks & Mitigations (table: risk, probability, impact, mitigation)
9. Open Questions (table: question, owner, status)
10. Milestones (regroup tasks.md into phases)
11. Review Signoff (table: role, reviewer, status)

## Style Guidelines

- Tables for structured data, ASCII/Mermaid for diagrams
- Concrete JSON examples for every API endpoint
- Follow the global Language Rule
- Mark uncertain items with TBD

## Incremental Update Mode

When tech-proposal.md already exists: diff against current OpenSpec artifacts, add update note at top, only modify changed sections.
SKILL_EOF

info "tech-proposal SKILL.md 创建完成"

# ─── Step 7: Stop Hook ────────────────────────

echo ""
echo "--- Step 7/8: Stop Hook ---"

cat > "$SCRIPTS_DIR/workflow-reminder.sh" << 'HOOK_EOF'
#!/bin/bash
# workflow-reminder.sh — Stop Hook 工作流提醒
# 轻量检查文件系统状态，输出提醒文字
# 不阻塞、不强制——纯提醒

REMINDERS=""

# 检查 1: 活跃的 OpenSpec 变更未归档
if [ -d "openspec/changes" ]; then
  for dir in openspec/changes/*/; do
    [ -d "$dir" ] || continue
    [[ "$dir" == *archive* ]] && continue
    if [ -f "${dir}tasks.md" ]; then
      CHANGE_NAME=$(basename "$dir")
      REMINDERS="${REMINDERS}\n- 活跃的 OpenSpec 变更 [${CHANGE_NAME}] 尚未归档"
    fi
  done
fi

# 检查 2: knowledge/ 存在但缺少 index.md
if [ -d "knowledge" ] && [ ! -f "knowledge/index.md" ]; then
  REMINDERS="${REMINDERS}\n- knowledge/ 目录存在但缺少 index.md，建议运行 /compound-knowledge 创建索引"
fi

# 输出提醒（仅在有提醒时输出）
if [ -n "$REMINDERS" ]; then
  echo -e "⚠️ 工作流提醒：${REMINDERS}"
fi
HOOK_EOF

chmod +x "$SCRIPTS_DIR/workflow-reminder.sh"
info "workflow-reminder.sh 创建完成"

# 更新 settings.json（保留已有配置，添加 hooks）
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  # 检查是否已有 Stop hook
  if python3 -c "import json; d=json.load(open('$SETTINGS_FILE')); exit(0 if 'hooks' in d else 1)" 2>/dev/null; then
    info "settings.json 已包含 hooks 配置，跳过"
  else
    # 用 python3 安全地合并 hooks 到已有 settings.json
    python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    d = json.load(f)
d['hooks'] = {
    'Stop': [{
        'matcher': '',
        'hooks': [{
            'type': 'command',
            'command': 'bash ~/.claude/scripts/workflow-reminder.sh'
        }]
    }]
}
with open('$SETTINGS_FILE', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
" 2>/dev/null && info "settings.json 已添加 Stop Hook" || warn "settings.json 更新失败，请手动添加 hooks"
  fi
else
  cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/scripts/workflow-reminder.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  info "settings.json 创建完成（含 Stop Hook）"
fi

# ─── Step 8: OpenSpec 全局 Skill + 衔接修补 ──

echo ""
echo "--- Step 8/8: OpenSpec 全局 Skill ---"

TEMP_INIT_DIR=$(mktemp -d)
cd "$TEMP_INIT_DIR"
git init -q
openspec init --tools claude 2>/dev/null || true
cd - > /dev/null

PROPOSE_SKILL="$SKILLS_DIR/openspec-propose/SKILL.md"
if [ -f "$PROPOSE_SKILL" ]; then
  if grep -q "run /opsx:apply" "$PROPOSE_SKILL" 2>/dev/null; then
    sed -i.bak 's|When ready to implement, run /opsx:apply|When ready to implement, use Superpowers writing-plans to decompose each task, then subagent-driven-development to execute.|' "$PROPOSE_SKILL"
    sed -i.bak 's|Run `/opsx:apply` or ask me to implement to start working on the tasks.|Ready for implementation. Use Superpowers writing-plans to decompose each task into tactical steps, then subagent-driven-development to execute.|' "$PROPOSE_SKILL"
    rm -f "${PROPOSE_SKILL}.bak"
    info "openspec-propose 衔接指令已修补"
  else
    info "openspec-propose 衔接指令无需修补"
  fi
else
  warn "openspec-propose skill 未找到（请手动运行 openspec init --tools claude）"
fi

rm -rf "$TEMP_INIT_DIR"
info "OpenSpec 全局 Skill 配置完成"

# ─── 完成 ─────────────────────────────────────

echo ""
echo "=========================================="
echo -e "  ${GREEN}安装完成！${NC}"
echo "=========================================="
echo ""
echo "还需要手动完成一步："
echo ""
echo "  在 Claude Code 中运行："
echo "  /plugin install superpowers@claude-plugins-official"
echo ""
echo "验证方法："
echo "  在 Claude Code 中运行 /skills，确认看到："
echo "  - multi-review, compound-knowledge, tech-proposal"
echo "  - openspec-propose, openspec-explore, ..."
echo "  - superpowers:brainstorming, superpowers:writing-plans, ..."
echo ""
echo "新项目初始化："
echo "  cd your-project && openspec init --tools claude"
echo "  mkdir -p knowledge/{patterns,anti-patterns,decisions,subsystem-specs}"
echo ""
echo "详细文档：team-harness-setup-guide.md"
echo ""
