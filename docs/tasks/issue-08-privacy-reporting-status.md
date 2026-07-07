# Issue 08: Complete privacy, reporting, and status transitions

Labels: `v1`, `privacy`, `moderation`, `p1`
Priority: P1
Source: `website-product-spec.md` sections 10, 12, 14

## Goal

确保真人答题者只能看到必要且脱敏的上下文，并支持举报后暂停任务分发。

## Scope

- 隐私文本打码。
- 原图访问控制。
- 未打码举报。
- 任务状态转换。
- 超时关闭规则。

## Checklist

- [ ] 真人任务响应不包含 `askerId`。
- [ ] 真人任务响应不包含原始 `imageUrl`。
- [ ] 真人任务响应不包含昵称、头像、手机号、微信号、二维码、地址等身份信息。
- [ ] 举报 `unmasked_private_info` 后创建 `ModerationReport`。
- [ ] 被举报问题从真人任务池移除。
- [ ] `expiresAt <= now` 后禁止真人继续提交。
- [ ] 结果页仍展示 AI 回答和已可见真人回答。
- [ ] 添加隐私和状态转换测试。
- [ ] 提交：`feat: enforce privacy and reporting rules`。

## Acceptance Criteria

- [ ] 真人答题者不可看到提问者身份。
- [ ] 未打码举报后任务暂停分发。
- [ ] 超时后不允许继续提交真人回答。
