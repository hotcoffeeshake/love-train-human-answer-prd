# Issue 05: Implement ask flow and question result page

Labels: `v1`, `frontend`, `p0`
Priority: P0
Source: `website-product-spec.md` sections 4, 5, 7, 12

## Goal

把首页从营销优先改为提问优先，并新增问题结果页展示 AI 与真人回答。

## Scope

- 首页提问主屏。
- `AskForm` 组件。
- `/questions/:id` 结果页。
- `QuestionResult` 组件。

## Checklist

- [ ] 首页首屏包含场景选择、文本输入、截图上传入口、隐私提醒、提交按钮。
- [ ] 提问正文不足 10 字时禁止提交。
- [ ] 提交成功后跳转 `/questions/:id`。
- [ ] 结果页展示问题状态、AI 回答、真人回答等待状态。
- [ ] 结果页轮询或刷新获取真人回答。
- [ ] 提问者可以选择最佳答案。
- [ ] 已 resolved 的问题不能重复选择。
- [ ] 添加组件测试。
- [ ] 提交：`feat: add question ask flow and result page`。

## Acceptance Criteria

- [ ] 用户从首页能完成真实提问。
- [ ] 用户能在结果页看到 AI 回答和后续真人回答。
- [ ] 刷新后问题和回答状态不丢失。
