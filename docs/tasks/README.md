# LoveTrain Human Answer V1 Task Cards

这些文件是从 `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md` 拆出的 GitHub Issue 草稿。当前仓库是 PRD/静态原型仓库，因此这些任务卡默认用于真实 LoveTrain 应用仓库；如果继续在本仓库开发，需要先增加 full-stack 应用骨架。

执行顺序：

1. `issue-01-baseline.md`
2. `issue-02-persistence-model.md`
3. `issue-03-domain-services.md`
4. `issue-04-backend-apis-ai.md`
5. `issue-05-ask-result-ui.md`
6. `issue-06-human-desk-api.md`
7. `issue-07-rewards-abuse-guards.md`
8. `issue-08-privacy-reporting-status.md`
9. `issue-09-e2e-tests.md`
10. `issue-10-release-readiness.md`

关键验收链路：网页提问 -> 后端 Question -> 真人任务池 -> 真人 Answer -> 提问者结果页 -> RewardLedger。

实施状态（2026-07-11）：任务卡已复制并在 `/Volumes/CopilotDisk/A_Work/Joshua/love-train-mp` 的 `feat/lovetrain-human-answer-v1` 分支执行。后端核心实现、本地自动化测试和独立 HTTP smoke 已通过，但该仓库不是当前 Vercel 生产网站源码。生产站仍运行本仓库的 mock 脚本且缺少 `/api/*`；issue 09 的真实生产网站/浏览器变体与 issue 10 的部署预览验收仍待完成。详见 `docs/PRODUCTION_SOURCE_AUDIT.md` 和目标仓库的 `docs/lovetrain-human-answer-v1/completion-audit.md`。
