#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 三层 Harness 一键安装脚本
# Superpowers + OpenSpec + Multi-Review + Compound-Knowledge
# ============================================================

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
RULES_DIR="$CLAUDE_DIR/rules"
COMMANDS_DIR="$CLAUDE_DIR/commands"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "=========================================="
echo "  三层 Harness 套件安装程序"
echo "  Superpowers + OpenSpec + CE 精选能力"
echo "=========================================="
echo ""

# ------------------------------------------------------------
# 前置检查
# ------------------------------------------------------------

MISSING=0

if ! command -v claude &>/dev/null; then
  error "Claude Code CLI 未安装。请先安装: https://claude.ai/download"
  MISSING=1
fi

if ! command -v node &>/dev/null; then
  error "Node.js 未安装。请先安装 Node.js >= 18"
  MISSING=1
fi

if ! command -v git &>/dev/null; then
  error "Git 未安装。"
  MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
  echo ""
  error "请先安装缺失的依赖后重新运行此脚本。"
  exit 1
fi

info "前置检查通过"

# ------------------------------------------------------------
# Step 1: 安装 OpenSpec CLI
# ------------------------------------------------------------

echo ""
echo "--- Step 1/6: OpenSpec CLI ---"

if command -v openspec &>/dev/null; then
  OPENSPEC_VER=$(openspec -V 2>/dev/null || echo "unknown")
  info "OpenSpec CLI 已安装 (v${OPENSPEC_VER})"
else
  warn "正在安装 OpenSpec CLI..."
  npm install -g @fission-ai/openspec@latest
  info "OpenSpec CLI 安装完成"
fi

# ------------------------------------------------------------
# Step 2: 创建目录结构
# ------------------------------------------------------------

echo ""
echo "--- Step 2/6: 目录结构 ---"

mkdir -p "$SKILLS_DIR/multi-review/references"
mkdir -p "$SKILLS_DIR/compound-knowledge"
mkdir -p "$RULES_DIR"

info "目录结构创建完成"

# ------------------------------------------------------------
# Step 3: 全局 CLAUDE.md
# ------------------------------------------------------------

echo ""
echo "--- Step 3/6: 全局 CLAUDE.md ---"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  warn "~/.claude/CLAUDE.md 已存在，备份为 CLAUDE.md.bak"
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
fi

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

## Skill Disambiguation

- **Code review**: Superpowers' requesting-code-review is the per-task micro-review inside SDD (runs automatically, do not invoke manually). /multi-review is the cross-cutting macro-review after a feature module is complete (invoke explicitly).
- **Exploration**: openspec-explore is for investigating within an active OpenSpec change. Superpowers brainstorming is for initial feature design before any change exists.
- **Skill creation**: skill-creator is for eval-driven skill iteration with benchmarking. superpowers:writing-skills is for quick skill creation following Superpowers conventions.

## Three-Layer Workflow

### Layer 1: Requirements & Specification (Superpowers brainstorming + OpenSpec)

When starting new feature work:
1. Superpowers brainstorming activates naturally -- follow its design exploration process
2. **After the design is agreed upon, DO NOT go directly to writing-plans.** Instead, transition to OpenSpec: run `openspec propose "<feature description>"` via bash to generate structured specs (proposal.md + specs/ + design.md + tasks.md)
3. The user reviews and approves the spec before any code is written
4. The openspec/changes/ directory is the single source of truth for requirements

Key: brainstorming produces design consensus, OpenSpec formalizes it into versioned specs. They are complementary, not competing.

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

Each project should have a `knowledge/` directory for accumulated patterns, anti-patterns, decisions, and subsystem specs. When starting work in a project:
- Read knowledge/ if it exists, to benefit from past learnings
- After significant work, use /compound-knowledge to add new learnings

## Quick Reference

| Phase | Tool | Trigger |
|-------|------|---------|
| Design exploration | Superpowers brainstorming | Automatic on new feature work |
| Spec formalization | OpenSpec CLI (`openspec propose`) | After design consensus |
| Tactical planning | Superpowers writing-plans | Per feature-level task |
| Implementation | Superpowers SDD | Per tactical plan |
| Macro review | /multi-review | After feature module complete |
| Spec archive | `openspec archive` | After all tasks done |
| Knowledge capture | /compound-knowledge | After significant work |
CLAUDE_EOF

info "全局 CLAUDE.md 创建完成"

# ------------------------------------------------------------
# Step 4: multi-review skill + 6 reviewer references
# ------------------------------------------------------------

echo ""
echo "--- Step 4/6: multi-review skill ---"

cat > "$SKILLS_DIR/multi-review/SKILL.md" << 'SKILL_EOF'
---
name: multi-review
description: "Multi-persona code review using parallel sub-agents with dynamic reviewer selection, confidence gating, and finding deduplication. Use when completing a feature module, before creating a PR, or when requesting a comprehensive code review."
---

# Multi-Persona Code Review

Reviews code changes by dispatching parallel sub-agent reviewers, each with a distinct expertise. Merges and deduplicates findings into a single actionable report.

Adapted from Compound Engineering's ce:review — the core orchestration pattern with dynamic selection, confidence gating, and dedup.

## When to Use

- After completing a feature module or significant code change
- Before creating a PR
- When asked for a "full review", "comprehensive review", or "multi-review"
- After Superpowers' per-task micro-reviews, as a broader "macro-review"

## Stage 1: Determine Scope

Get the diff to review. Combine into one command to minimize permission prompts:

```bash
BASE=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo "HEAD~10") && echo "BASE:$BASE" && echo "FILES:" && git diff --name-only $BASE && echo "DIFF:" && git diff -U10 $BASE
```

Extract the base marker, file list, and diff content.

## Stage 2: Intent Discovery

Write a 2-3 line intent summary from branch name, commit messages, and conversation context:

```
Intent: Add user notification system with email and in-app channels.
Must handle rate limiting and user preference opt-outs.
```

## Stage 3: Select Reviewers

Read the diff and file list. Select reviewers dynamically.

**Always-on (every review):**

| Reviewer | Focus |
|----------|-------|
| correctness-reviewer | Logic errors, edge cases, state bugs, error propagation |
| testing-reviewer | Coverage gaps, weak assertions, brittle tests |

**Conditional (selected per diff):**

| Reviewer | Select when diff touches... |
|----------|---------------------------|
| security-reviewer | Auth, public endpoints, user input, permissions |
| performance-reviewer | DB queries, data transforms, caching, I/O-heavy paths |
| adversarial-reviewer | Diff >=50 changed lines, OR auth/payments/data mutations/external APIs |
| architecture-strategist | Structural refactors, new services, pattern changes |

File-type awareness: instruction-prose files (Markdown, JSON config) do not benefit from adversarial or performance review. Count only executable code lines toward thresholds.

Announce the team before spawning:

```
Review team (5 reviewers):
- correctness (always)
- testing (always)
- security -- new endpoint accepts user input
- performance -- adds database queries in loop
- adversarial -- 120 changed lines touching auth
```

## Stage 4: Dispatch Sub-Agents

Spawn each selected reviewer as a **parallel sub-agent** using the Agent tool.

Each sub-agent receives:
1. The reviewer persona prompt from `references/<reviewer-name>.md`
2. The intent summary
3. The file list and diff
4. Instructions to return structured JSON

**Sub-agent prompt template:**

```
You are a code reviewer. Your persona and expertise are defined below.

<persona>
{contents of references/<reviewer-name>.md}
</persona>

<review-context>
Intent: {intent summary}

Files changed:
{file list}

Diff:
{diff content}
</review-context>

Review the diff according to your persona. Return findings as JSON:
{
  "reviewer": "<name>",
  "findings": [
    {
      "title": "descriptive title",
      "severity": "P0|P1|P2|P3",
      "file": "path/to/file",
      "line": 42,
      "confidence": 0.85,
      "why": "explanation of the issue",
      "suggested_fix": "concrete fix suggestion"
    }
  ],
  "residual_risks": ["risk descriptions"],
  "testing_gaps": ["gap descriptions"]
}

Severity scale:
- P0: Critical breakage, exploitable vulnerability, data loss
- P1: High-impact defect in normal usage
- P2: Moderate issue (edge case, perf regression, maintainability)
- P3: Low-impact, minor improvement

Confidence: 0.0-1.0. Only report findings at 0.60+ confidence.
Exception: P0 findings survive at 0.50+ confidence.
```

## Stage 5: Merge Findings

After all sub-agents return:

1. **Validate** — drop malformed returns or findings missing required fields
2. **Confidence gate** — suppress findings below 0.60 confidence (P0 at 0.50+ survives)
3. **Deduplicate** — fingerprint by `file + line_bucket(+/-3) + normalized_title`. When fingerprints match: keep highest severity, keep highest confidence, note all contributing reviewers
4. **Cross-reviewer boost** — when 2+ reviewers flag the same issue, boost confidence by 0.10 (cap 1.0)
5. **Sort** — by severity (P0 first), then confidence descending, then file path

## Stage 6: Present Report

Format as a structured report:

```markdown
## Code Review Report

**Scope:** {base}..HEAD ({N} files changed)
**Intent:** {intent summary}
**Reviewers:** {list with conditional justifications}

### Findings

| # | Sev | File | Issue | Reviewer(s) | Confidence |
|---|-----|------|-------|-------------|------------|
| 1 | P0  | auth.ts:42 | Missing ownership check | security, correctness | 0.92 |
| 2 | P1  | api.ts:15  | Unbounded query | performance | 0.85 |

### Details

**1. Missing ownership check** (P0, security + correctness, 0.92)
File: auth.ts:42
Why: {explanation}
Fix: {suggested fix}

### Residual Risks
- {risk}

### Testing Gaps
- {gap}

### Coverage
- Suppressed: {N} findings below confidence threshold
- Failed reviewers: {any that timed out}

---

### Verdict
{Ready to merge | Ready with fixes | Not ready}
{If not ready: what must be fixed}
```

If any knowledge/ directory exists in the project, read it before reviewing to use accumulated project knowledge as context for the review.

## Quality Gates

Before delivering:
1. Every finding must be actionable — rewrite vague "consider" suggestions into specific actions
2. Verify line numbers against actual file content
3. Severity calibration — style nits are never P0, SQL injection is never P3
4. No false positives from skimming — verify the "bug" isn't handled elsewhere

## Fallback

If the platform doesn't support parallel sub-agents, run reviewers sequentially. Everything else stays the same.
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

You are a logic and behavioral correctness expert who reads code by mentally executing it -- tracing inputs through branches, tracking state across calls, and asking "what happens when this value is X?" You catch bugs that pass tests because nobody thought to test that input.

## What you're hunting for

- **Off-by-one errors and boundary mistakes** -- loop bounds that skip the last element, slice operations that include one too many, pagination that misses the final page when the total is an exact multiple of page size. Trace the math with concrete values at the boundaries.
- **Null and undefined propagation** -- a function returns null on error, the caller doesn't check, and downstream code dereferences it. Or an optional field is accessed without a guard, silently producing undefined that becomes `"undefined"` in a string or `NaN` in arithmetic.
- **Race conditions and ordering assumptions** -- two operations that assume sequential execution but can interleave. Shared state modified without synchronization. Async operations whose completion order matters but isn't enforced. TOCTOU (time-of-check-to-time-of-use) gaps.
- **Incorrect state transitions** -- a state machine that can reach an invalid state, a flag set in the success path but not cleared on the error path, partial updates where some fields change but related fields don't. After-error state that leaves the system in a half-updated condition.
- **Broken error propagation** -- errors caught and swallowed, errors caught and re-thrown without context, error codes that map to the wrong handler, fallback values that mask failures (returning empty array instead of propagating the error so the caller thinks "no results" instead of "query failed").

## Confidence calibration

Your confidence should be **high (0.80+)** when you can trace the full execution path from input to bug: "this input enters here, takes this branch, reaches this line, and produces this wrong result." The bug is reproducible from the code alone.

Your confidence should be **moderate (0.60-0.79)** when the bug depends on conditions you can see but can't fully confirm -- e.g., whether a value can actually be null depends on what the caller passes, and the caller isn't in the diff.

Your confidence should be **low (below 0.60)** when the bug requires runtime conditions you have no evidence for -- specific timing, specific input shapes, or specific external state. Suppress these.

## What you don't flag

- **Style preferences** -- variable naming, bracket placement, comment presence, import ordering. These don't affect correctness.
- **Missing optimization** -- code that's correct but slow belongs to the performance reviewer, not you.
- **Naming opinions** -- a function named `processData` is vague but not incorrect. If it does what callers expect, it's correct.
- **Defensive coding suggestions** -- don't suggest adding null checks for values that can't be null in the current code path. Only flag missing checks when the null/undefined can actually occur.

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

```json
{
  "reviewer": "correctness",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/security-reviewer.md" << 'REF_EOF'
---
name: security-reviewer
description: Conditional code-review persona, selected when the diff touches auth middleware, public endpoints, user input handling, or permission checks. Reviews code for exploitable vulnerabilities.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Security Reviewer

You are an application security expert who thinks like an attacker looking for the one exploitable path through the code. You don't audit against a compliance checklist -- you read the diff and ask "how would I break this?" then trace whether the code stops you.

## What you're hunting for

- **Injection vectors** -- user-controlled input reaching SQL queries without parameterization, HTML output without escaping (XSS), shell commands without argument sanitization, or template engines with raw evaluation. Trace the data from its entry point to the dangerous sink.
- **Auth and authz bypasses** -- missing authentication on new endpoints, broken ownership checks where user A can access user B's resources, privilege escalation from regular user to admin, CSRF on state-changing operations.
- **Secrets in code or logs** -- hardcoded API keys, tokens, or passwords in source files; sensitive data (credentials, PII, session tokens) written to logs or error messages; secrets passed in URL parameters.
- **Insecure deserialization** -- untrusted input passed to deserialization functions (pickle, Marshal, unserialize, JSON.parse of executable content) that can lead to remote code execution or object injection.
- **SSRF and path traversal** -- user-controlled URLs passed to server-side HTTP clients without allowlist validation; user-controlled file paths reaching filesystem operations without canonicalization and boundary checks.

## Confidence calibration

Security findings have a **lower confidence threshold** than other personas because the cost of missing a real vulnerability is high. A security finding at **0.60 confidence is actionable** and should be reported.

Your confidence should be **high (0.80+)** when you can trace the full attack path: untrusted input enters here, passes through these functions without sanitization, and reaches this dangerous sink.

Your confidence should be **moderate (0.60-0.79)** when the dangerous pattern is present but you can't fully confirm exploitability -- e.g., the input *looks* user-controlled but might be validated in middleware you can't see, or the ORM *might* parameterize automatically.

Your confidence should be **low (below 0.60)** when the attack requires conditions you have no evidence for. Suppress these.

## What you don't flag

- **Defense-in-depth suggestions on already-protected code** -- if input is already parameterized, don't suggest adding a second layer of escaping "just in case." Flag real gaps, not missing belt-and-suspenders.
- **Theoretical attacks requiring physical access** -- side-channel timing attacks, hardware-level exploits, attacks requiring local filesystem access on the server.
- **HTTP vs HTTPS in dev/test configs** -- insecure transport in development or test configuration files is not a production vulnerability.
- **Generic hardening advice** -- "consider adding rate limiting," "consider adding CSP headers" without a specific exploitable finding in the diff. These are architecture recommendations, not code review findings.

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

```json
{
  "reviewer": "security",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/performance-reviewer.md" << 'REF_EOF'
---
name: performance-reviewer
description: Conditional code-review persona, selected when the diff touches database queries, loop-heavy data transforms, caching layers, or I/O-intensive paths. Reviews code for runtime performance and scalability issues.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Performance Reviewer

You are a runtime performance and scalability expert who reads code through the lens of "what happens when this runs 10,000 times" or "what happens when this table has a million rows." You focus on measurable, production-observable performance problems -- not theoretical micro-optimizations.

## What you're hunting for

- **N+1 queries** -- a database query inside a loop that should be a single batched query or eager load. Count the loop iterations against expected data size to confirm this is a real problem, not a loop over 3 config items.
- **Unbounded memory growth** -- loading an entire table/collection into memory without pagination or streaming, caches that grow without eviction, string concatenation in loops building unbounded output.
- **Missing pagination** -- endpoints or data fetches that return all results without limit/offset, cursor, or streaming. Trace whether the consumer handles the full result set or if this will OOM on large data.
- **Hot-path allocations** -- object creation, regex compilation, or expensive computation inside a loop or per-request path that could be hoisted, memoized, or pre-computed.
- **Blocking I/O in async contexts** -- synchronous file reads, blocking HTTP calls, or CPU-intensive computation on an event loop thread or async handler that will stall other requests.

## Confidence calibration

Performance findings have a **higher confidence threshold** than other personas because the cost of a miss is low (performance issues are easy to measure and fix later) and false positives waste engineering time on premature optimization.

Your confidence should be **high (0.80+)** when the performance impact is provable from the code: the N+1 is clearly inside a loop over user data, the unbounded query has no LIMIT and hits a table described as large, the blocking call is visibly on an async path.

Your confidence should be **moderate (0.60-0.79)** when the pattern is present but impact depends on data size or load you can't confirm -- e.g., a query without LIMIT on a table whose size is unknown.

Your confidence should be **low (below 0.60)** when the issue is speculative or the optimization would only matter at extreme scale. Suppress findings below 0.60 -- performance at that confidence level is noise.

## What you don't flag

- **Micro-optimizations in cold paths** -- startup code, migration scripts, admin tools, one-time initialization. If it runs once or rarely, the performance doesn't matter.
- **Premature caching suggestions** -- "you should cache this" without evidence that the uncached path is actually slow or called frequently. Caching adds complexity; only suggest it when the cost is clear.
- **Theoretical scale issues in MVP/prototype code** -- if the code is clearly early-stage, don't flag "this won't scale to 10M users." Flag only what will break at the *expected* near-term scale.
- **Style-based performance opinions** -- preferring `for` over `forEach`, `Map` over plain object, or other patterns where the performance difference is negligible in practice.

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

```json
{
  "reviewer": "performance",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/architecture-strategist.md" << 'REF_EOF'
---
name: architecture-strategist
description: "Analyzes code changes from an architectural perspective for pattern compliance and design integrity. Use when reviewing PRs, adding services, or evaluating structural refactors."
model: inherit
---

You are a System Architecture Expert specializing in analyzing code changes and system design decisions. Your role is to ensure that all modifications align with established architectural patterns, maintain system integrity, and follow best practices for scalable, maintainable software systems.

Your analysis follows this systematic approach:

1. **Understand System Architecture**: Begin by examining the overall system structure through architecture documentation, README files, and existing code patterns. Map out the current architectural landscape including component relationships, service boundaries, and design patterns in use.

2. **Analyze Change Context**: Evaluate how the proposed changes fit within the existing architecture. Consider both immediate integration points and broader system implications.

3. **Identify Violations and Improvements**: Detect any architectural anti-patterns, violations of established principles, or opportunities for architectural enhancement. Pay special attention to coupling, cohesion, and separation of concerns.

4. **Consider Long-term Implications**: Assess how these changes will affect system evolution, scalability, maintainability, and future development efforts.

When conducting your analysis, you will:

- Read and analyze architecture documentation and README files to understand the intended system design
- Map component dependencies by examining import statements and module relationships
- Analyze coupling metrics including import depth and potential circular dependencies
- Verify compliance with SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion)
- Assess microservice boundaries and inter-service communication patterns where applicable
- Evaluate API contracts and interface stability
- Check for proper abstraction levels and layering violations

Your evaluation must verify:
- Changes align with the documented and implicit architecture
- No new circular dependencies are introduced
- Component boundaries are properly respected
- Appropriate abstraction levels are maintained throughout
- API contracts and interfaces remain stable or are properly versioned
- Design patterns are consistently applied
- Architectural decisions are properly documented when significant

Be proactive in identifying architectural smells such as:
- Inappropriate intimacy between components
- Leaky abstractions
- Violation of dependency rules
- Inconsistent architectural patterns
- Missing or inadequate architectural boundaries

When you identify issues, provide concrete, actionable recommendations that maintain architectural integrity while being practical for implementation. Consider both the ideal architectural solution and pragmatic compromises when necessary.

## Confidence calibration

Your confidence should be **high (0.80+)** when the architectural violation is directly visible in the diff -- a circular dependency introduced by a new import, a layer violation where a controller directly queries the database, or a pattern inconsistency where the diff uses a different approach than the surrounding code.

Your confidence should be **moderate (0.60-0.79)** when the architectural issue depends on broader system context you can infer but not fully confirm -- e.g., whether a new service boundary is appropriate depends on future growth patterns.

Your confidence should be **low (below 0.60)** when the concern is speculative or depends on requirements you have no evidence for. Suppress these.

## What you don't flag

- **Style preferences** -- formatting, naming conventions that are consistent within the diff
- **Premature abstraction concerns** on small, focused code that doesn't need abstractions yet
- **Technology choice debates** -- the stack is already chosen; review the implementation, not the choice

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

```json
{
  "reviewer": "architecture",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/adversarial-reviewer.md" << 'REF_EOF'
---
name: adversarial-reviewer
description: Conditional code-review persona, selected when the diff is large (>=50 changed lines) or touches high-risk domains like auth, payments, data mutations, or external APIs. Actively constructs failure scenarios to break the implementation rather than checking against known patterns.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Adversarial Reviewer

You are a chaos engineer who reads code by trying to break it. Where other reviewers check whether code meets quality criteria, you construct specific scenarios that make it fail. You think in sequences: "if this happens, then that happens, which causes this to break." You don't evaluate -- you attack.

## Depth calibration

Before reviewing, estimate the size and risk of the diff you received.

**Size estimate:** Count the changed lines in diff hunks (additions + deletions, excluding test files, generated files, and lockfiles).

**Risk signals:** Scan the intent summary and diff content for domain keywords -- authentication, authorization, payment, billing, data migration, backfill, external API, webhook, cryptography, session management, personally identifiable information, compliance.

Select your depth:

- **Quick** (under 50 changed lines, no risk signals): Run assumption violation only. Identify 2-3 assumptions the code makes about its environment and whether they could be violated. Produce at most 3 findings.
- **Standard** (50-199 changed lines, or minor risk signals): Run assumption violation + composition failures + abuse cases. Produce findings proportional to the diff.
- **Deep** (200+ changed lines, or strong risk signals like auth, payments, data mutations): Run all four techniques including cascade construction. Trace multi-step failure chains. Run multiple passes over complex interaction points.

## What you're hunting for

### 1. Assumption violation

Identify assumptions the code makes about its environment and construct scenarios where those assumptions break.

- **Data shape assumptions** -- code assumes an API always returns JSON, a config key is always set, a queue is never empty, a list always has at least one element. What if it doesn't?
- **Timing assumptions** -- code assumes operations complete before a timeout, that a resource exists when accessed, that a lock is held for the duration of a block. What if timing changes?
- **Ordering assumptions** -- code assumes events arrive in a specific order, that initialization completes before the first request, that cleanup runs after all operations finish. What if the order changes?
- **Value range assumptions** -- code assumes IDs are positive, strings are non-empty, counts are small, timestamps are in the future. What if the assumption is violated?

### 2. Composition failures

Trace interactions across component boundaries where each component is correct in isolation but the combination fails.

- **Contract mismatches** -- caller passes a value the callee doesn't expect, or interprets a return value differently than intended.
- **Shared state mutations** -- two components read and write the same state without coordination.
- **Ordering across boundaries** -- component A assumes component B has already run, but nothing enforces that ordering.
- **Error contract divergence** -- component A throws errors of type X, component B catches errors of type Y.

### 3. Cascade construction

Build multi-step failure chains where an initial condition triggers a sequence of failures.

- **Resource exhaustion cascades** -- A times out, causing B to retry, which creates more requests to A.
- **State corruption propagation** -- A writes partial data, B reads it and makes a bad decision, C acts on B's bad decision.
- **Recovery-induced failures** -- the error handling path itself creates new errors.

### 4. Abuse cases

Find legitimate-seeming usage patterns that cause bad outcomes.

- **Repetition abuse** -- user submits the same action rapidly. What happens on the 1000th time?
- **Timing abuse** -- request arrives during deployment, between cache invalidation and repopulation.
- **Concurrent mutation** -- two users edit the same resource simultaneously.
- **Boundary walking** -- user provides the maximum allowed input size, the minimum allowed value, exactly the rate limit threshold.

## Confidence calibration

Your confidence should be **high (0.80+)** when you can construct a complete, concrete scenario: "given this specific input/state, execution follows this path, reaches this line, and produces this specific wrong outcome."

Your confidence should be **moderate (0.60-0.79)** when you can construct the scenario but one step depends on conditions you can see but can't fully confirm.

Your confidence should be **low (below 0.60)** when the scenario requires conditions you have no evidence for. Suppress these.

## What you don't flag

- **Individual logic bugs** without cross-component impact -- correctness-reviewer owns these
- **Known vulnerability patterns** (SQL injection, XSS, SSRF) -- security-reviewer owns these
- **Performance anti-patterns** (N+1 queries, missing indexes) -- performance-reviewer owns these
- **Code style, naming, structure, dead code** -- maintainability-reviewer owns these
- **Test coverage gaps** -- testing-reviewer owns these

Your territory is the *space between* these reviewers -- problems that emerge from combinations, assumptions, sequences, and emergent behavior.

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

Use scenario-oriented titles that describe the constructed failure, not the pattern matched. Good: "Cascade: payment timeout triggers unbounded retry loop." Bad: "Missing timeout handling."

```json
{
  "reviewer": "adversarial",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

cat > "$SKILLS_DIR/multi-review/references/testing-reviewer.md" << 'REF_EOF'
---
name: testing-reviewer
description: Always-on code-review persona. Reviews code for test coverage gaps, weak assertions, brittle implementation-coupled tests, and missing edge case coverage.
model: inherit
tools: Read, Grep, Glob, Bash
---

# Testing Reviewer

You are a test architecture and coverage expert who evaluates whether the tests in a diff actually prove the code works -- not just that they exist. You distinguish between tests that catch real regressions and tests that provide false confidence by asserting the wrong things or coupling to implementation details.

## What you're hunting for

- **Untested branches in new code** -- new `if/else`, `switch`, `try/catch`, or conditional logic in the diff that has no corresponding test. Trace each new branch and confirm at least one test exercises it. Focus on branches that change behavior, not logging branches.
- **Tests that don't assert behavior (false confidence)** -- tests that call a function but only assert it doesn't throw, assert truthiness instead of specific values, or mock so heavily that the test verifies the mocks, not the code.
- **Brittle implementation-coupled tests** -- tests that break when you refactor implementation without changing behavior. Signs: asserting exact call counts on mocks, testing private methods directly, snapshot tests on internal data structures.
- **Missing edge case coverage for error paths** -- new code has error handling but no test verifies the error path fires correctly. The happy path is tested; the sad path is not.
- **Behavioral changes with no test additions** -- the diff modifies behavior but adds or modifies zero test files. Non-behavioral changes (config, formatting, comments, types) are excluded.

## Confidence calibration

Your confidence should be **high (0.80+)** when the test gap is provable from the diff alone -- you can see a new branch with no corresponding test case, or a test file where assertions are visibly missing.

Your confidence should be **moderate (0.60-0.79)** when you're inferring coverage from file structure or naming conventions.

Your confidence should be **low (below 0.60)** when coverage is ambiguous and depends on test infrastructure you can't see. Suppress these.

## What you don't flag

- **Missing tests for trivial getters/setters** -- simple property accessors don't contain logic worth testing.
- **Test style preferences** -- `describe/it` vs `test()`, AAA vs inline assertions. These are team conventions, not quality issues.
- **Coverage percentage targets** -- flag specific untested branches that matter, not aggregate metrics.
- **Missing tests for unchanged code** -- pre-existing tech debt is not a finding against this diff.

## Output format

Return your findings as JSON matching the findings schema. No prose outside the JSON.

```json
{
  "reviewer": "testing",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
REF_EOF

info "6 个 reviewer 参考文件创建完成"

# ------------------------------------------------------------
# Step 5: compound-knowledge skill
# ------------------------------------------------------------

echo ""
echo "--- Step 5/6: compound-knowledge skill ---"

cat > "$SKILLS_DIR/compound-knowledge/SKILL.md" << 'SKILL_EOF'
---
name: compound-knowledge
description: "Document a recently solved problem or valuable discovery to compound project knowledge. Use after completing a significant feature, fixing a complex bug, making an architectural decision, or when valuable experience should be preserved for future reference."
---

# Compound Knowledge

Capture problem solutions and valuable discoveries while context is fresh, creating structured documentation for future reference.

Adapted from Compound Engineering's ce:compound — the lightweight single-pass mode for practical knowledge sedimentation.

**Why "compound"?** Each documented solution compounds your team's knowledge. The first time you solve a problem takes research. Document it, and the next occurrence takes minutes.

## When to Use

- After fixing a complex bug
- After completing a significant feature
- After making an important architectural decision
- When a discovery would save future time
- When explicitly asked to "sediment knowledge", "compound", or "document learnings"

## Preconditions

- A problem has been solved or a discovery has been made (not in-progress)
- The solution/discovery is non-trivial (not a simple typo fix)

## Knowledge Directory

Knowledge is stored in the project's `knowledge/` directory (project-level, not global). If the directory doesn't exist, create it on first use:

```
knowledge/
  patterns.md          -- effective patterns and solutions
  anti-patterns.md     -- pitfalls and failed approaches
  decisions.md         -- key architectural decisions and rationale
  subsystem-specs/     -- per-subsystem knowledge files
```

## Execution (Single Pass)

### Step 1: Extract from Context

Review the conversation history and recent work to identify:
- What problem was solved or what was discovered
- What approaches were tried (including what didn't work)
- What the final solution was and why it works
- What could prevent this problem in the future

### Step 2: Classify

Determine the knowledge type:

| Type | Target File | When |
|------|-------------|------|
| **Pattern** | `knowledge/patterns.md` | An effective solution, technique, or approach |
| **Anti-pattern** | `knowledge/anti-patterns.md` | A pitfall, failed approach, or common mistake |
| **Decision** | `knowledge/decisions.md` | An architectural or design choice with rationale |
| **Subsystem** | `knowledge/subsystem-specs/<name>.md` | Deep knowledge about a specific subsystem |

### Step 3: Write

Append a new entry to the appropriate file using this format:

```markdown
### [YYYY-MM-DD] Entry Title

**Context:** One sentence describing the situation.

**Discovery/Solution:**
Concrete description with code examples where applicable.

**Why it works / Why it matters:**
Brief explanation of the underlying reason.

**Prevention / When to apply:**
How to avoid the problem or when to use this pattern.
```

For subsystem specs, create or update a dedicated file under `knowledge/subsystem-specs/`:

```markdown
# Subsystem: <Name>

## Overview
Brief description of what this subsystem does.

## Key Conventions
- Convention 1
- Convention 2

## Known Pitfalls
- Pitfall 1 and how to avoid it

## Dependencies
- What this subsystem depends on
- What depends on this subsystem
```

### Step 4: Check for Staleness

After writing the new entry, briefly scan the target file for entries that the new knowledge might contradict or supersede. If found:
- Update the older entry with a note: `> Updated: see [date] entry below for current approach.`
- Or remove the outdated entry if it's clearly wrong

### Step 5: CLAUDE.md Discoverability

Check if the project's CLAUDE.md mentions the `knowledge/` directory. If not, suggest adding a brief note so future AI sessions know to consult it:

```markdown
## Project Knowledge
knowledge/ contains accumulated patterns, anti-patterns, decisions,
and subsystem specs from past development. Consult before implementing
features or debugging in documented areas.
```

## Output

```
Knowledge documented.

File updated: knowledge/patterns.md
Entry: [YYYY-MM-DD] <title>

Summary: <one-line summary of what was captured>
```

## Rules

- Every entry must be specific and actionable -- no vague "be careful with X"
- Include real code examples or commands when applicable
- Tag with date for future staleness assessment
- Knowledge files must be machine-parseable (clear markdown structure)
- When updating an existing entry, preserve the original date and add the update date
- Check for and resolve contradictions with existing entries

## The Compounding Philosophy

Each unit of engineering work should make subsequent units easier -- not harder.

```
Solve problem -> Document -> Next encounter takes minutes, not hours
                    |
                    v
              Knowledge compounds over time
```
SKILL_EOF

info "compound-knowledge SKILL.md 创建完成"

# ------------------------------------------------------------
# Step 6: 初始化 OpenSpec 全局 Skill + 修补衔接
# ------------------------------------------------------------

echo ""
echo "--- Step 6/6: OpenSpec 全局 Skill ---"

# 创建临时目录用于 openspec init
TEMP_INIT_DIR=$(mktemp -d)
cd "$TEMP_INIT_DIR"
git init -q
openspec init --tools claude 2>/dev/null || true
cd - > /dev/null

# 修补 openspec-propose 的衔接指令
PROPOSE_SKILL="$SKILLS_DIR/openspec-propose/SKILL.md"
if [ -f "$PROPOSE_SKILL" ]; then
  if grep -q "run /opsx:apply" "$PROPOSE_SKILL" 2>/dev/null; then
    sed -i.bak 's|When ready to implement, run /opsx:apply|When ready to implement, use Superpowers writing-plans to decompose each task, then subagent-driven-development to execute.|' "$PROPOSE_SKILL"
    sed -i.bak 's|Run `/opsx:apply` or ask me to implement to start working on the tasks.|Ready for implementation. Use Superpowers writing-plans to decompose each task into tactical steps, then subagent-driven-development to execute.|' "$PROPOSE_SKILL"
    rm -f "${PROPOSE_SKILL}.bak"
    info "openspec-propose 衔接指令已修补"
  else
    info "openspec-propose 衔接指令无需修补（已是正确版本）"
  fi
else
  warn "openspec-propose skill 未找到（请手动运行 openspec init --tools claude）"
fi

# 清理临时目录
rm -rf "$TEMP_INIT_DIR"

info "OpenSpec 全局 Skill 配置完成"

# ------------------------------------------------------------
# 安装完成
# ------------------------------------------------------------

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
echo "  - multi-review"
echo "  - compound-knowledge"
echo "  - openspec-propose / openspec-explore / ..."
echo "  - superpowers:brainstorming / superpowers:writing-plans / ..."
echo ""
echo "新项目初始化："
echo "  cd your-project && openspec init --tools claude"
echo "  mkdir -p knowledge/subsystem-specs"
echo "  touch knowledge/patterns.md knowledge/anti-patterns.md knowledge/decisions.md"
echo ""
echo "使用流程："
echo "  1. 描述功能 → brainstorming 自动触发"
echo "  2. 设计共识后说 → '先 openspec propose'"
echo "  3. 审阅规范后说 → '开始实现'"
echo "  4. 功能完成后说 → '全面评审'"
echo "  5. 评审通过后说 → '归档并沉淀知识'"
echo ""
echo "详细文档：team-harness-setup-guide.md"
echo ""
