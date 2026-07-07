# Issue 01: Establish LoveTrain Human Answer V1 baseline

Labels: `v1`, `setup`, `documentation`
Priority: P0
Source: `website-product-spec.md`, `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md`

## Goal

确认真实 LoveTrain 应用仓库，建立开发分支，并创建 V1 测试记录文件。

## Scope

- 确认目标仓库是可运行应用仓库，而不是 PRD/静态原型仓库。
- 创建 `feat/lovetrain-human-answer-v1` 分支。
- 创建 `docs/v1-human-answer-test-record.md`。

## Checklist

- [ ] 运行 `pwd && git remote -v` 确认目标仓库。
- [ ] 检查是否存在 `package.json`、应用入口、后端/API 结构、数据库配置。
- [ ] 创建开发分支：`git checkout -b feat/lovetrain-human-answer-v1`。
- [ ] 添加 V1 测试记录文档。
- [ ] 提交：`docs: add LoveTrain human answer V1 test record`。

## Acceptance Criteria

- [ ] 真实应用仓库已确认。
- [ ] 开发分支已创建。
- [ ] 测试记录文档存在，并列出 API/E2E/手工验收项目。
