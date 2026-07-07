# Issue 07: Add reward ledger integration and abuse guards

Labels: `v1`, `backend`, `rewards`, `p1`
Priority: P1
Source: `website-product-spec.md` sections 8, 11, 12, 14

## Goal

实现参与奖励和被选中奖励，并增加 V1 级别的防刷保护。

## Scope

- `GET /api/rewards/me`
- 奖励余额/流水展示。
- 重复奖励保护。
- 每日参与奖励上限。

## Checklist

- [ ] 真人提交回答后创建 `RewardLedger(delta=1, reason=submit_answer)`。
- [ ] 真人回答被选中后创建 `RewardLedger(delta=5, reason=selected_answer)`。
- [ ] 同一个问题重复提交不重复奖励。
- [ ] 同一个问题重复选择不重复奖励。
- [ ] 每个用户每日最多 50 次参与奖励。
- [ ] `GET /api/rewards/me` 返回余额、今日参与数、今日被选中数、最近流水。
- [ ] 添加奖励相关测试。
- [ ] 提交：`feat: add reward ledger integration`。

## Acceptance Criteria

- [ ] 参与奖励和被选中奖励都有可追踪后端流水。
- [ ] 刷新页面后奖励状态不丢失。
- [ ] 重复或异常操作不会产生重复奖励。
