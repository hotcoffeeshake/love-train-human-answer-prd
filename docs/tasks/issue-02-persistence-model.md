# Issue 02: Add Question / Answer / Reward persistence models

Labels: `v1`, `backend`, `database`, `p0`
Priority: P0
Source: `website-product-spec.md` sections 8, 11, 12

## Goal

为 AI + 真人共同回答闭环增加可持久化的数据模型。

## Scope

- 增加 `Question`。
- 增加 `Answer`。
- 增加 `RewardLedger`。
- 增加 `ModerationReport`。
- 增加必要枚举、索引、唯一约束。

## Checklist

- [ ] 在数据库 schema 中增加问题状态：`submitted`、`ai_answered`、`human_answering`、`resolved`、`closed`、`reported`。
- [ ] 在数据库 schema 中增加回答类型：`ai`、`human`。
- [ ] 在数据库 schema 中增加回答状态：`pending`、`visible`、`selected`、`reported`、`hidden`。
- [ ] 增加奖励原因：`submit_answer`、`selected_answer`、`manual_adjust`。
- [ ] 生成并运行数据库迁移。
- [ ] 验证同一真人用户不能对同一问题重复提交 human answer。
- [ ] 提交：`feat: add human answer persistence models`。

## Acceptance Criteria

- [ ] 新问题、AI 回答、真人回答、奖励流水、举报记录都能持久化。
- [ ] AI 回答和真人回答能挂在同一个 `questionId` 下。
- [ ] 奖励流水可以追踪 `userId`、`questionId`、`answerId`、`delta`、`reason`。
