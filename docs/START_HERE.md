# LoveTrain Human Answer V1 Start Here

这个仓库当前是 LoveTrain Human Answer V1 的 PRD/静态原型与开发规划入口。真正端到端开发应在真实 LoveTrain 应用仓库执行；本仓库负责保留产品规格、开发计划、任务卡和交接说明。

## 当前实施状态（2026-07-11）

后端与替代网页实现已经交接到：

- 本地路径：`/Volumes/CopilotDisk/A_Work/Joshua/love-train-mp`
- GitHub：`https://github.com/hotcoffeeshake/love-train-mp`
- 分支：`feat/lovetrain-human-answer-v1`
- 实施入口：`love-train-mp/docs/lovetrain-human-answer-v1/README.md`
- 完成度审计：`love-train-mp/docs/lovetrain-human-answer-v1/completion-audit.md`
- 测试记录：`love-train-mp/docs/v1-human-answer-test-record.md`

重要边界：`love-train-mp` 不是当前 Vercel 生产网站的源码仓库。公开审计确认生产 `/human-answer.js` 仍与本仓库 mock 脚本完全一致，且 `/api/questions`、`/api/human/tasks`、`/api/chat` 均为 404。详见 `docs/PRODUCTION_SOURCE_AUDIT.md`。

因此当前状态是：后端核心代码与本地自动化/HTTP 验证完成；真实生产网站源码/访问、前端接入、部署预览浏览器验收和 app 上游交付仍未完成。

## 1. 先读这些文件

阅读顺序：

1. `website-product-spec.md`
   - V1 产品规格 / PRD。
   - 明确成功标准、数据模型、接口、隐私边界、验收标准和测试计划。
2. `GOAL.md`
   - Codex goal 的目标、当前仓库现实、阶段划分、阻塞项和非协商验收链路。
3. `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md`
   - 可执行开发计划。
   - 包含文件结构、API contract、任务步骤、验收清单。
4. `docs/tasks/README.md`
   - 本地 GitHub Issue 草稿索引。
5. `docs/tasks/issue-01-baseline.md` 到 `docs/tasks/issue-10-release-readiness.md`
   - 实际开发时逐个执行的任务卡。
6. `docs/PRODUCTION_SOURCE_AUDIT.md`
   - 生产网站与当前仓库的关系、公开探测证据、完成 V1 所需的源码和权限。

## 2. 当前仓库不能直接完成的部分

当前仓库没有完整应用运行时，因此不能在这里直接完成这些 V1 代码要求：

- `POST /api/questions` 等后端 API。
- `Question` / `Answer` / `RewardLedger` / `ModerationReport` 数据库表。
- 登录/session。
- AI 生成服务。
- 自动化测试与 E2E 测试。
- 真实部署。

这些内容必须在真实 LoveTrain 应用仓库中实现，或先把本仓库升级成 full-stack 应用。

## 3. 目标应用仓库接入步骤

拿到真实 LoveTrain 应用仓库后：

1. 克隆或进入真实应用仓库。
2. 创建分支：

```bash
git checkout -b feat/lovetrain-human-answer-v1
```

3. 复制或引用以下文件：

```bash
GOAL.md
docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md
docs/tasks/
```

4. 从 `docs/tasks/issue-01-baseline.md` 开始执行。
5. 每完成一个 issue，运行该 issue 的验证命令并提交一次。
6. 最终以 `docs/v1-human-answer-test-record.md` 记录自动化与手工验收结果。

## 4. GitHub Issue 创建方式

如果当前 GitHub 账号有目标仓库写权限，可以使用：

```bash
bash docs/scripts/create-github-issues.sh --dry-run
bash docs/scripts/create-github-issues.sh --repo OWNER/REPO
bash docs/scripts/create-github-issues.sh --repo OWNER/REPO --with-labels
```

说明：

- `--dry-run` 只打印将要创建的 issue，不写入 GitHub。
- `--repo OWNER/REPO` 会调用 `gh issue create` 创建 issue；默认不附加 label，避免目标仓库缺少 label 时失败。
- `--with-labels` 会按任务卡中的 `Labels:` 附加 label，使用前请先确认目标仓库已有这些 label。
- 建议在真实 LoveTrain 应用仓库创建 issue，而不是在这个 PRD 仓库创建。

## 5. 非协商验收链路

V1 只有在以下链路全部可用且有测试证据时才算完成：

1. 网页用户提交问题。
2. 后端创建 `Question`。
3. AI 回答写成 `Answer(type=ai)`。
4. 真人答题台通过真实接口看到该问题。
5. 真人提交回答。
6. 后端写入 `Answer(type=human)`。
7. 后端写入 `RewardLedger(+1, submit_answer)`。
8. 提问者结果页同时显示 AI 和真人回答。
9. 提问者选择真人答案。
10. 后端写入 `RewardLedger(+5, selected_answer)`。
11. 刷新页面后状态仍然存在。
