# Harness-Best

Claude Code 三层 Harness 最佳实践套件。融合三大社区插件的核心能力，一键配置。

## 它解决什么问题

AI 编码助手裸跑时倾向于：跳过需求分析直接写代码、不写测试、自我评估虚高、经验不积累。本套件通过三层架构 + 禁止规则 + 自动提醒系统性解决这些问题：

| 层 | 职责 | 工具来源 |
|:---|:-----|:---------|
| **Layer 1 规范** | 设计探索 + 结构化规范 + 技术方案评审 | [Superpowers](https://github.com/obra/superpowers) brainstorming + [OpenSpec](https://github.com/Fission-AI/OpenSpec) |
| **Layer 2 执行** | TDD + 子 agent 隔离 + 双阶段微审查 | [Superpowers](https://github.com/obra/superpowers) SDD |
| **Layer 3 质量/知识** | 多维宏审查 + 按主题知识沉淀 | 从 [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) 提取 |

## 核心设计原则

- **禁止规则优先** — LLM 对"禁止做 X"的遵守率远高于"应该做 Y"，CLAUDE.md 使用 7 条绝对禁止规则
- **知识按需加载** — knowledge/index.md 轻量索引 (< 500 tokens)，具体文件按需读取，防止上下文膨胀
- **Hook 自动提醒** — Stop Hook 在 Claude 停止时检查未归档变更和缺失索引
- **人类是最终关卡** — 不引入 verify.sh 强制验证，harness 管纪律，人管决策

## 快速开始

```bash
git clone https://github.com/heqiu12345/Harness-Best.git
cd Harness-Best
chmod +x install-harness.sh
./install-harness.sh
```

然后在 Claude Code 中运行：

```
/plugin install superpowers@claude-plugins-official
```

运行 `/skills` 验证安装。

## 使用流程

```
描述功能 → brainstorming 自动触发
         → 说"先 openspec propose"生成规范
         → (可选) 说"生成技术方案"供团队评审
         → 审阅后说"开始实现"
         → Superpowers TDD + 子 agent 自动执行
         → 说"全面评审"触发 multi-review
         → 说"归档并沉淀知识"完成闭环
         → Stop Hook 自动检查是否有遗漏
```

## 安装脚本做了什么

| 步骤 | 内容 |
|:-----|:-----|
| 1 | 安装 OpenSpec CLI |
| 2 | 创建 `~/.claude/` 目录结构 |
| 3 | 写入全局 `CLAUDE.md`（禁止规则 + 三层协奏 + 工作流覆盖 + Skill 消歧） |
| 4 | 创建 `multi-review` skill + 6 个 reviewer 子 agent 参考文件 |
| 5 | 创建 `compound-knowledge` skill（按主题拆分 + index.md 索引） |
| 6 | 创建 `tech-proposal` skill（可选的跨团队技术方案生成） |
| 7 | 创建 Stop Hook 脚本 + 配置 settings.json |
| 8 | 初始化 OpenSpec 全局 skill + 修补衔接指令 |

## 新项目初始化

```bash
cd your-project
openspec init --tools claude
mkdir -p knowledge/{patterns,anti-patterns,decisions,subsystem-specs}
```

首次运行 `/compound-knowledge` 时会自动创建 `knowledge/index.md`。

## 文件说明

| 文件 | 说明 |
|:-----|:-----|
| `install-harness.sh` | 一键安装脚本 |
| `team-harness-setup-guide.md` | 完整使用文档（架构 / 安装 / 工作流 / FAQ / 维护） |

## 致谢

- **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — 执行纪律框架
- **[OpenSpec](https://github.com/Fission-AI/OpenSpec)** by Fission AI — 规范驱动开发 CLI
- **[Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)** by Every Inc — 多维评审与知识复利

## License

MIT
