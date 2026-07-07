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

Status: blocked until real LoveTrain app repository is available

Required input:

- Real LoveTrain application repository path or Git URL.
- Confirmation of stack: Next.js/React or other.
- Database provider and schema location.
- Existing auth/session helper location.
- Existing `/api/chat` or AI generation implementation location.

Expected action after repository is available:

- Create branch `feat/lovetrain-human-answer-v1`.
- Copy/keep `GOAL.md`, implementation plan, and task cards in the target repository.
- Execute issues 01-10 in order.

### Phase 2: V1 implementation

Status: pending target app repository

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

## Immediate Next Step

If continuing inside this PRD/prototype repo:

- Commit the planning package.
- Optionally create actual GitHub Issues from `docs/tasks/*.md` if GitHub write access is available.

If continuing with real development:

- Provide the real LoveTrain app repository path or Git URL.
- Then execute `docs/tasks/issue-01-baseline.md` first.
