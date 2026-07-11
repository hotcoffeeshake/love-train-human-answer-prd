# GOAL: LoveTrain Human Answer V1 Development

## Objective

按照 `website-product-spec.md` 和 `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md` 推进 LoveTrain 网站端 AI + 真人共同回答 V1：让用户在网页提交恋爱/情感问题后，问题能持久化进入后端，AI 立即回答，真人答题台从真实任务池读取并提交回答，提问者在结果页看到 AI 与真人回答，并能选择最佳答案触发奖励流水。

## Current Repository Reality

当前仓库 `love-train-human-answer-prd` 是 PRD/静态原型仓库，不是完整应用工程。

已有：

- `website-product-spec.md`：V1 产品规格 / PRD。
- `index.html`：静态首页原型。
- `human-answer.html`：真人答题台静态页面。
- `human-answer.css`：真人答题台样式。
- `human-answer.js`：真人答题台 mock 交互。
- `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md`：详细开发计划。
- `docs/tasks/`：GitHub Issue 草稿 / 本地任务卡。
- `docs/START_HERE.md`：实施入口与交接说明。
- `docs/scripts/create-github-issues.sh`：从任务卡创建 GitHub Issues 的辅助脚本。
- `docs/PRODUCTION_SOURCE_AUDIT.md`：生产网站、源码归属和访问条件审计。
- `docs/scripts/audit-production-source.sh`：可重复运行的只读生产审计脚本。

缺少：

- `package.json`。
- 后端 API。
- 数据库 schema / migration。
- 认证/session。
- AI 生成服务接入代码。
- 自动化测试工程。
- 部署配置。

## Development Strategy

### Phase 0: Planning package in this PRD repo

Status: ready for target app handoff

Deliverables:

- [x] Clone and inspect PRD/prototype repository.
- [x] Identify PRD: `website-product-spec.md`.
- [x] Create detailed implementation plan.
- [x] Split implementation plan into local GitHub Issue drafts under `docs/tasks/`.
- [x] Create this `GOAL.md`.
- [x] Start Codex goal tracking for this objective.
- [x] Add `docs/START_HERE.md` as the implementation entry point.
- [x] Add `docs/scripts/create-github-issues.sh` for optional GitHub Issue creation.

### Phase 1: Target app repository handoff

Status: backend candidate handoff completed; canonical production website source unresolved

Available implementation candidate:

- Local path: `/Volumes/CopilotDisk/A_Work/Joshua/love-train-mp`.
- GitHub: `https://github.com/hotcoffeeshake/love-train-mp`.
- Branch: `feat/lovetrain-human-answer-v1`.
- Stack: Fastify backend, CloudBase/MongoDB adapter, existing AI provider abstraction, WeChat identity, and native Mini Program.
- Website adaptation: minimal ask/result/human-desk pages are served directly by Fastify under `/`, `/questions/:id`, and `/human-answer`.
- Production-source caveat: this repository is not the source currently serving `love-train-v12.vercel.app` or `r2i84a.chat`.

Completed handoff:

- [x] Create branch `feat/lovetrain-human-answer-v1`.
- [x] Copy `GOAL.md`, implementation plan, task cards, scripts, and implementation entry into the target repository.
- [x] Add a target-stack assessment and test record.
- [x] Execute the implementation portions of issues 01-09.
- [x] Audit the public Vercel deployments and prove that production still serves the static mock.
- [ ] Obtain the canonical production website source/archive or authenticated Vercel project access.
- [ ] Complete issue 10 browser/deployed-preview verification and upstream delivery.

### Phase 2: V1 implementation

Status: substitute Fastify implementation and local verification complete; production website integration pending

Implementation order:

1. Baseline and test record.
2. Persistence model.
3. Validation, sanitization, and domain services.
4. Backend APIs and AI answer persistence.
5. Homepage ask flow and question result page.
6. Human answer desk real API integration.
7. Rewards and abuse guards.
8. Privacy, reporting, and status transitions.
9. E2E tests.
10. Release readiness verification.

Current evidence in the target app repository (2026-07-11):

- Backend: 17 test files / 75 tests pass.
- Mini Program regression: 2 files / 8 tests pass.
- Lint, typecheck, E2E, build, environment check, MongoDB transaction/concurrency tests, and standalone HTTP smoke pass.
- Completion audit: `love-train-mp/docs/lovetrain-human-answer-v1/completion-audit.md`.
- Test record: `love-train-mp/docs/v1-human-answer-test-record.md`.
- Production source audit: `docs/PRODUCTION_SOURCE_AUDIT.md`.
- Production evidence: deployed `human-answer.js` is byte-for-byte the same mock script as this repository, and required `/api/*` routes return 404.
- Remaining: canonical website source/access, frontend integration, real browser/manual smoke on a deployed preview, and branch delivery to an app repository with write access.

## Non-Negotiable Acceptance Chain

V1 is accepted only when this real persisted chain works:

1. Website user submits a question.
2. Backend creates `Question`.
3. AI answer is written as `Answer(type=ai)` under the same question.
4. Question appears in `GET /api/human/tasks`.
5. Human answerer submits an answer.
6. Backend writes `Answer(type=human)` under the same question.
7. Backend writes `RewardLedger(+1, submit_answer)`.
8. Asker result page shows AI and human answers together.
9. Asker selects best human answer.
10. Backend writes `RewardLedger(+5, selected_answer)`.
11. Refreshing pages preserves state.

## Task Sources

- PRD: `website-product-spec.md`
- Implementation plan: `docs/superpowers/plans/2026-07-07-lovetrain-human-answer-v1.md`
- Task cards: `docs/tasks/`
- Production source audit: `docs/PRODUCTION_SOURCE_AUDIT.md`

## Immediate Next Step

Resolve the canonical website handoff before claiming completion:

1. Provide the source path/archive used for the current Vercel deployment, authenticated Vercel access, or an explicit decision to promote an available repository as canonical.
2. Connect the canonical website frontend to the implemented API/backend.
3. Obtain a deployed preview URL and browser-capable session.
4. Run the browser/manual chain and `BASE_URL=https://<preview-host> npm run smoke:human-answer`.
5. Update the target app test record with deployed evidence.
6. Push the app feature branch through an account with write access, or use an approved fork/PR workflow. The currently active accounts have read-only access to the upstream app repository.
