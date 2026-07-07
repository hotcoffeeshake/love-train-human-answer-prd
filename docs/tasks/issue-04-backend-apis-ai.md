# Issue 04: Implement backend APIs and AI answer persistence

Labels: `v1`, `backend`, `api`, `ai`, `p0`
Priority: P0
Source: `website-product-spec.md` sections 7, 9, 12

## Goal

实现 PRD 要求的真实 API，让网页提问、AI 回答、真人任务池、真人提交、选择答案形成后端闭环。

## API Scope

- `POST /api/questions`
- `GET /api/questions/:id`
- `POST /api/questions/:id/select-answer`
- `GET /api/human/tasks`
- `POST /api/human/answers`
- `GET /api/rewards/me`
- `POST /api/moderation/report`

## Checklist

- [ ] `POST /api/questions` 创建 `Question`，返回 `questionId` 和结果页 URL。
- [ ] 创建问题后触发 AI 回答，并写入 `Answer(type=ai)`。
- [ ] `GET /api/questions/:id` 返回问题详情和可见回答。
- [ ] `GET /api/human/tasks` 返回真实任务池，不能返回 mock 数据。
- [ ] `POST /api/human/answers` 写入 `Answer(type=human)` 和 `RewardLedger(+1)`。
- [ ] `POST /api/questions/:id/select-answer` 支持提问者选择最佳答案，并为真人答案写入 `RewardLedger(+5)`。
- [ ] `POST /api/moderation/report` 支持未打码举报并暂停分发。
- [ ] 添加 API 测试。
- [ ] 提交：`feat: add human answer API endpoints`。

## Acceptance Criteria

- [ ] 真实提交的问题能进入后端。
- [ ] 真人答题台 API 能读到该问题。
- [ ] 真人回答能写回后端。
- [ ] AI 回答和真人回答能在同一个问题下查询。
