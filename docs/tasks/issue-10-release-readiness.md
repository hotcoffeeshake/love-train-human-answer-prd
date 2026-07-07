# Issue 10: Verify release readiness

Labels: `v1`, `release`, `verification`, `p0`
Priority: P0
Source: `website-product-spec.md` sections 12, 13, 15

## Goal

在预览环境完成自动化和人工验收，确保 V1 达到上线口径。

## Scope

- 环境变量检查。
- lint/test/e2e/build。
- 预览部署 smoke test。
- 测试记录更新。

## Checklist

- [ ] 确认数据库环境变量。
- [ ] 确认 AI 生成能力或现有 `/api/chat` 可用。
- [ ] 确认登录/session 配置。
- [ ] 确认截图上传存储配置，或关闭未接入的上传路径。
- [ ] 运行 `npm run lint`。
- [ ] 运行 `npm test`。
- [ ] 运行 `npm run test:e2e`。
- [ ] 运行 `npm run build`。
- [ ] 在预览部署手动完成核心链路。
- [ ] 更新 `docs/v1-human-answer-test-record.md`。
- [ ] 提交：`docs: record human answer V1 release verification`。

## Acceptance Criteria

- [ ] 自动化验证全部通过。
- [ ] 手动链路验证通过。
- [ ] 测试记录文档包含日期、环境、命令、结果和结论。
