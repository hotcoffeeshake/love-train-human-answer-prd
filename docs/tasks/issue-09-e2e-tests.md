# Issue 09: Add end-to-end tests for V1 chain

Labels: `v1`, `testing`, `e2e`, `p0`
Priority: P0
Source: `website-product-spec.md` section 13

## Goal

用自动化端到端测试证明 PRD 的核心链路可用。

## Scope

- `tests/e2e/lovetrain-human-answer.spec.ts`
- 测试用户 A：提问者。
- 测试用户 B：真人答题者。
- 奖励流水验证。

## Checklist

- [ ] 用户 A 从首页提交问题。
- [ ] A 跳转到 `/questions/:id`。
- [ ] AI 回答状态或 AI 回答卡出现。
- [ ] 用户 B 打开 `/human-answer`。
- [ ] B 能看到 A 的问题。
- [ ] B 提交真人回答。
- [ ] A 的结果页显示真人回答。
- [ ] A 选择 B 的真人回答为最佳答案。
- [ ] B 的奖励流水包含 `+1` 和 `+5`。
- [ ] 更新 `docs/v1-human-answer-test-record.md`。
- [ ] 提交：`test: cover LoveTrain human answer end-to-end flow`。

## Acceptance Criteria

- [ ] E2E 测试覆盖“网页提问 -> 答题台看到 -> 真人回答 -> 提问者看到回答 -> 选择答案 -> 奖励流水”。
- [ ] E2E 测试在本地或 CI 通过。
