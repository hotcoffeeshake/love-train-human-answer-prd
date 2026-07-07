# Issue 03: Add validation, sanitization, and domain services

Labels: `v1`, `backend`, `domain`, `p0`
Priority: P0
Source: implementation plan Task 3

## Goal

建立问题创建、结果查询、真人任务池、真人回答、答案选择的领域服务层。

## Scope

- `src/features/questions/types.ts`
- `src/features/questions/validation.ts`
- `src/features/questions/service.ts`
- `src/features/moderation/sanitize.ts`

## Checklist

- [ ] 定义 V1 场景：`不知道怎么回`、`对方变冷`、`吵架修复`、`聊天复盘`、`其他`。
- [ ] 校验提问正文至少 10 字，最多 5000 字。
- [ ] 校验真人回答至少 10 字，最多 1000 字。
- [ ] 实现手机号、邮箱、微信号等文本打码。
- [ ] 实现 `createQuestion`。
- [ ] 实现 `getQuestionResult`。
- [ ] 实现 `listHumanTasks`。
- [ ] 实现 `submitHumanAnswer`。
- [ ] 实现 `selectBestAnswer`。
- [ ] 为重复提交、超时提交、重复选择、权限错误添加测试。
- [ ] 提交：`feat: add human answer domain services`。

## Acceptance Criteria

- [ ] 服务层写操作使用事务保护奖励流水。
- [ ] 对真人任务池只返回可分发、已脱敏、未被举报暂停的问题。
- [ ] 无权限或重复操作返回可映射到 HTTP 状态的错误。
