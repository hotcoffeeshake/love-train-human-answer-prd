# Issue 06: Replace human answer desk mock data with real APIs

Labels: `v1`, `frontend`, `human-answer`, `p0`
Priority: P0
Source: `human-answer.html`, `human-answer.css`, `human-answer.js`, `website-product-spec.md`

## Goal

保留当前真人答题台原型的交互体验，但任务来源和提交目标必须改为真实后端 API。

## Scope

- `/human-answer` 页面。
- 真人任务池。
- 当前任务详情。
- 真人回答提交。
- 未打码举报。
- 奖励数据展示。

## Checklist

- [ ] 移除生产路径中的 `human-answer.js` mock 任务数组。
- [ ] 使用 `GET /api/human/tasks` 加载任务池。
- [ ] 保留 `全部 / 可答 / 即将超时` 筛选。
- [ ] 根据 `expiresAt` 展示倒计时和超时状态。
- [ ] 使用 `POST /api/human/answers` 提交真人回答。
- [ ] 提交成功后更新任务状态和奖励余额。
- [ ] 使用 `POST /api/moderation/report` 举报未打码内容。
- [ ] 提交：`feat: connect human answer desk to APIs`。

## Acceptance Criteria

- [ ] 真人答题台展示真实问题，而不是固定 mock 任务。
- [ ] 真人回答能生成后端 `Answer(type=human)`。
- [ ] 回答少于 10 字不能提交。
- [ ] 超时任务不能继续提交。
