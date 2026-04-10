# Harness-Best

Claude Code 三层 Harness 最佳实践套件。融合三大社区插件的核心能力，一键配置。

## 它解决什么问题

AI 编码助手裸跑时倾向于：跳过需求分析直接写代码、不写测试、自我评估虚高、经验不积累。本套件通过三层架构系统性解决这些问题：

| 层 | 职责 | 工具来源 |
|:---|:-----|:---------|
| **Layer 1 规范** | 设计探索 + 结构化规范 | [Superpowers](https://github.com/obra/superpowers) brainstorming + [OpenSpec](https://github.com/Fission-AI/OpenSpec) |
| **Layer 2 执行** | TDD + 子 agent 隔离 + 双阶段微审查 | [Superpowers](https://github.com/obra/superpowers) SDD |
| **Layer 3 质量/知识** | 多维宏审查 + 知识沉淀 | 从 [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) 提取 |

## 快速开始

```bash
# 1. 克隆
git clone https://github.com/YOUR_USERNAME/Harness-Best.git
cd Harness-Best

# 2. 运行安装脚本
chmod +x install-harness.sh
./install-harness.sh

# 3. 在 Claude Code 中安装 Superpowers 插件
# 打开 Claude Code，运行：
/plugin install superpowers@claude-plugins-official

# 4. 验证
# 在 Claude Code 中运行 /skills，确认看到 multi-review、compound-knowledge、openspec-* 和 superpowers:*
```

## 使用流程

```
描述功能 → brainstorming 自动触发
         → 说"先 openspec propose"生成规范
         → 审阅后说"开始实现"
         → Superpowers TDD + 子 agent 自动执行
         → 说"全面评审"触发 multi-review
         → 说"归档并沉淀知识"完成闭环
```

## 文件说明

```
install-harness.sh              一键安装脚本（自动配置全局 skill + 规则 + 衔接修补）
team-harness-setup-guide.md     完整使用文档（架构 / 安装 / 工作流 / FAQ / 维护）
```

## 安装脚本做了什么

| 步骤 | 内容 |
|:-----|:-----|
| 1 | 安装 OpenSpec CLI |
| 2 | 创建 `~/.claude/` 目录结构 |
| 3 | 写入全局 `CLAUDE.md`（三层协奏规则 + 工作流覆盖 + Skill 消歧） |
| 4 | 创建 `multi-review` skill + 6 个 reviewer 子 agent 参考文件 |
| 5 | 创建 `compound-knowledge` skill |
| 6 | 初始化 OpenSpec 全局 skill + 修补衔接指令 |

## 新项目初始化

每个项目首次使用时：

```bash
cd your-project
openspec init --tools claude
mkdir -p knowledge/subsystem-specs
touch knowledge/patterns.md knowledge/anti-patterns.md knowledge/decisions.md
```

`openspec/` 和 `knowledge/` 提交到 git，团队自动共享规范和知识。

## 致谢

本套件基于以下开源项目构建：

- **[Superpowers](https://github.com/obra/superpowers)** by Jesse Vincent — 执行纪律框架（TDD、子 agent 驱动开发、反合理化设计）
- **[OpenSpec](https://github.com/Fission-AI/OpenSpec)** by Fission AI — 规范驱动开发 CLI（制品依赖图、Delta Spec 演进）
- **[Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin)** by Every Inc — 多维评审 agent 和知识复利机制

## License

MIT
