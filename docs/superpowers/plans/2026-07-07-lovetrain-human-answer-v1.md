# LoveTrain Human Answer V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the V1 end-to-end LoveTrain Q&A loop where a website question is persisted, answered by AI, distributed to the human answer desk, answered by a human, shown back on the result page, and rewarded through auditable ledger records.

**Architecture:** Treat this repository as the PRD/prototype source and implement the feature in the real LoveTrain application repository. Add a domain layer around `Question`, `Answer`, `RewardLedger`, and `ModerationReport`; expose stable JSON APIs for the ask flow, result page, human answer desk, rewards, and reporting. The human desk UI should reuse the current prototype interaction model but load and submit real data instead of `human-answer.js` mock tasks.

**Tech Stack:** Target implementation assumes the production LoveTrain app is a Vercel-hosted Next.js/React app with TypeScript, route handlers, Prisma/PostgreSQL or an equivalent relational database, existing `/api/chat` AI generation capability, and Vitest/Playwright for tests. If the production stack differs, preserve the data model, API contracts, status transitions, and acceptance tests below.

---

## Source Findings

- PRD exists: `website-product-spec.md`.
- PRD update date: 2026-07-06.
- PRD target version: V1.
- Current repository files:
  - `website-product-spec.md`: Product spec / PRD for website-side AI + human Q&A.
  - `index.html`: Static homepage prototype with a `真人答题台` nav entry.
  - `human-answer.html`, `human-answer.css`, `human-answer.js`: Static human answer desk prototype.
- Current repository limitation: it has no `package.json`, no backend routes, no database schema, no test runner, and no deployment config. The V1 code delivery must therefore happen in the actual LoveTrain app repository, or this repo must first be converted into a full-stack app.
- PRD non-negotiable delivery bar: static pages are insufficient; the chain `网页提问 -> 后端 Question -> 真人任务池 -> 真人 Answer -> 提问者结果页 -> RewardLedger` must work with persisted data.

## File Structure to Implement in Target App

The following paths assume a Next.js App Router codebase under `src/`. If the target app uses another structure, keep the same responsibilities and API routes.

- Create or modify: `prisma/schema.prisma`
  - Owns `Question`, `Answer`, `RewardLedger`, `ModerationReport` models and enums.
- Create: `src/features/questions/types.ts`
  - Shared request/response DTOs and status enums used by API handlers and UI.
- Create: `src/features/questions/validation.ts`
  - Zod schemas for question creation, human answer submission, answer selection, and moderation report requests.
- Create: `src/features/questions/service.ts`
  - Transactional domain functions: create question, fetch result, list human tasks, submit human answer, select best answer.
- Create: `src/features/questions/ai-answer.ts`
  - Adapter that calls existing `/api/chat` logic or direct AI generation and stores the `ai` answer.
- Create: `src/features/moderation/sanitize.ts`
  - Text redaction, public task shaping, and screenshot visibility rules.
- Create or modify: `src/app/api/questions/route.ts`
  - `POST /api/questions`.
- Create or modify: `src/app/api/questions/[id]/route.ts`
  - `GET /api/questions/:id`.
- Create or modify: `src/app/api/questions/[id]/select-answer/route.ts`
  - `POST /api/questions/:id/select-answer`.
- Create or modify: `src/app/api/human/tasks/route.ts`
  - `GET /api/human/tasks`.
- Create or modify: `src/app/api/human/answers/route.ts`
  - `POST /api/human/answers`.
- Create or modify: `src/app/api/rewards/me/route.ts`
  - `GET /api/rewards/me`.
- Create or modify: `src/app/api/moderation/report/route.ts`
  - `POST /api/moderation/report`.
- Modify: `src/app/page.tsx` or the existing homepage component
  - Adds the V1 ask-first hero with scenario selector, text input, upload/privacy notice, and submit button.
- Create: `src/app/questions/[id]/page.tsx`
  - Result page showing question state, AI answer, human answers, waiting state, and best-answer selection.
- Create or modify: `src/app/human-answer/page.tsx`
  - Port of `human-answer.html` that uses real APIs.
- Create: `src/components/questions/AskForm.tsx`
  - Homepage ask form.
- Create: `src/components/questions/QuestionResult.tsx`
  - Result page answer comparison and selection UI.
- Create: `src/components/human-answer/HumanAnswerDesk.tsx`
  - Human task list, current task view, answer editor, report action, and reward stats.
- Create: `tests/api/questions.test.ts`
  - API/domain tests for question creation and result retrieval.
- Create: `tests/api/human-answer.test.ts`
  - API/domain tests for task listing, answer submission, duplicate protection, and reward ledger.
- Create: `tests/e2e/lovetrain-human-answer.spec.ts`
  - Browser test for the full V1 chain.
- Create: `docs/v1-human-answer-test-record.md`
  - Manual release checklist and E2E evidence record.

## API Contract

### `POST /api/questions`

Request:

```json
{
  "scenario": "对方变冷",
  "content": "她最近回复明显变慢，但没有明确拒绝。我应该继续主动还是先后撤？",
  "imageUrl": null,
  "ocrText": null
}
```

Response `201`:

```json
{
  "questionId": "q_123",
  "status": "submitted",
  "resultUrl": "/questions/q_123"
}
```

Rules:
- `content.trim().length >= 10`.
- `scenario` must be one of `不知道怎么回`, `对方变冷`, `吵架修复`, `聊天复盘`, `其他`.
- Create `Question` with `expiresAt = createdAt + 30 minutes`.
- Trigger AI answer generation; V1 can run it synchronously for simpler acceptance or enqueue it if the app already has a job runner.
- The question enters the human task pool immediately if it is privacy-safe.

### `GET /api/questions/:id`

Response `200`:

```json
{
  "question": {
    "id": "q_123",
    "scenario": "对方变冷",
    "content": "她最近回复明显变慢，但没有明确拒绝。我应该继续主动还是先后撤？",
    "status": "ai_answered",
    "expiresAt": "2026-07-07T04:30:00.000Z",
    "selectedAnswerId": null
  },
  "answers": [
    {
      "id": "a_ai_123",
      "type": "ai",
      "content": "先判断她的回复变慢是阶段性压力还是投入下降...",
      "status": "visible",
      "createdAt": "2026-07-07T04:01:00.000Z"
    }
  ]
}
```

Rules:
- Only the asker can select the best answer.
- Public response must not expose raw answerer identity.

### `GET /api/human/tasks`

Response `200`:

```json
{
  "tasks": [
    {
      "id": "q_123",
      "scenario": "对方变冷",
      "brief": "对方最近回复变慢，用户想判断是否继续主动。",
      "summary": "对方最近回复明显变慢，但没有明确拒绝。用户想判断现在是继续主动，还是先后撤。",
      "maskedImageUrl": null,
      "ocrText": null,
      "secondsRemaining": 1430,
      "status": "active",
      "reward": { "submit": 1, "selected": 5 }
    }
  ]
}
```

Rules:
- Return only non-closed, non-reported, privacy-safe questions.
- Exclude tasks already answered by the current human answerer.
- `status` is `active`, `urgent`, or `fallback` based on `expiresAt` and AI state.

### `POST /api/human/answers`

Request:

```json
{
  "questionId": "q_123",
  "content": "建议你先别追问是不是不想聊。可以先回应她最近压力大，再留一个低压力出口。"
}
```

Response `201`:

```json
{
  "answerId": "a_human_123",
  "rewardDelta": 1,
  "balance": 13
}
```

Rules:
- `content.trim().length >= 10`.
- Cannot submit after the human window is closed.
- Cannot submit more than once per `questionId` and `answererId`.
- In one transaction: create `Answer(type=human,status=visible)`, create `RewardLedger(delta=1,reason=submit_answer)`, and update reward balance.

### `POST /api/questions/:id/select-answer`

Request:

```json
{
  "answerId": "a_human_123"
}
```

Response `200`:

```json
{
  "questionId": "q_123",
  "selectedAnswerId": "a_human_123",
  "rewardDelta": 5
}
```

Rules:
- Only the asker can select.
- One question can be resolved once.
- If the selected answer is human, create `RewardLedger(delta=5,reason=selected_answer)`.
- Set selected answer status to `selected`; set question status to `resolved`.

### `POST /api/moderation/report`

Request:

```json
{
  "questionId": "q_123",
  "answerId": null,
  "reason": "unmasked_private_info"
}
```

Response `200`:

```json
{
  "reportId": "r_123",
  "taskPaused": true
}
```

Rules:
- Create `ModerationReport`.
- Pause human distribution for the reported question when reason is `unmasked_private_info`.

## Implementation Tasks

### Task 1: Establish implementation baseline

**Files:**
- Create: `docs/v1-human-answer-test-record.md`
- Modify: target app README or release notes file if one exists

- [ ] **Step 1: Confirm target app repository**

Run in the target app repository:

```bash
pwd
git remote -v
find . -maxdepth 2 -type f \( -name package.json -o -name "next.config.*" -o -name "prisma" \) -print
```

Expected:
- A production LoveTrain app repository is available.
- The repo contains an application runtime, not only static HTML prototypes.

- [ ] **Step 2: Create implementation branch**

```bash
git checkout -b feat/lovetrain-human-answer-v1
```

Expected: working tree is on `feat/lovetrain-human-answer-v1`.

- [ ] **Step 3: Add test record shell**

Create `docs/v1-human-answer-test-record.md`:

```markdown
# LoveTrain Human Answer V1 Test Record

Date: 2026-07-07
Branch: feat/lovetrain-human-answer-v1

## Automated Tests

- API tests: pending execution in this branch
- E2E tests: pending execution in this branch

## Manual E2E Chain

- Ask user submits question: pending execution in preview
- Human desk sees the question: pending execution in preview
- Human answer is submitted: pending execution in preview
- Asker result page shows AI and human answers: pending execution in preview
- Asker selects human answer: pending execution in preview
- Reward ledger records +1 and +5: pending execution in preview

## Release Decision

Status: blocked until automated and manual checks pass.
```

- [ ] **Step 4: Commit baseline documentation**

```bash
git add docs/v1-human-answer-test-record.md
git commit -m "docs: add LoveTrain human answer V1 test record"
```

Expected: one documentation commit exists.

### Task 2: Add persistence model

**Files:**
- Modify: `prisma/schema.prisma`
- Create or update migration files generated by Prisma
- Test: `tests/api/questions.test.ts`

- [ ] **Step 1: Add models and enums**

Add these models to `prisma/schema.prisma`, using existing `User` relation names where the app already defines users:

```prisma
enum QuestionStatus {
  submitted
  ai_answered
  human_answering
  resolved
  closed
  reported
}

enum AnswerType {
  ai
  human
}

enum AnswerStatus {
  pending
  visible
  selected
  reported
  hidden
}

enum RewardReason {
  submit_answer
  selected_answer
  manual_adjust
}

enum ReportReason {
  unmasked_private_info
  low_quality_answer
  unsafe_content
}

model Question {
  id               String         @id @default(cuid())
  askerId          String
  scenario         String
  content          String
  imageUrl         String?
  ocrText          String?
  maskedImageUrl   String?
  status           QuestionStatus @default(submitted)
  expiresAt        DateTime
  selectedAnswerId String?
  createdAt        DateTime       @default(now())
  updatedAt        DateTime       @updatedAt
  answers          Answer[]
  rewards          RewardLedger[]
  reports          ModerationReport[]

  @@index([status, expiresAt])
  @@index([askerId, createdAt])
}

model Answer {
  id          String       @id @default(cuid())
  questionId  String
  answererId  String
  type        AnswerType
  content     String
  status      AnswerStatus @default(visible)
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt
  question    Question     @relation(fields: [questionId], references: [id], onDelete: Cascade)
  rewards     RewardLedger[]
  reports     ModerationReport[]

  @@index([questionId, type])
  @@unique([questionId, answererId, type])
}

model RewardLedger {
  id         String       @id @default(cuid())
  userId     String
  questionId String
  answerId   String?
  delta      Int
  reason     RewardReason
  createdAt  DateTime     @default(now())
  question   Question     @relation(fields: [questionId], references: [id], onDelete: Cascade)
  answer     Answer?      @relation(fields: [answerId], references: [id], onDelete: SetNull)

  @@index([userId, createdAt])
  @@index([questionId])
}

model ModerationReport {
  id         String       @id @default(cuid())
  reporterId String
  questionId String
  answerId   String?
  reason     ReportReason
  createdAt  DateTime     @default(now())
  question   Question     @relation(fields: [questionId], references: [id], onDelete: Cascade)
  answer     Answer?      @relation(fields: [answerId], references: [id], onDelete: SetNull)

  @@index([questionId, createdAt])
}
```

- [ ] **Step 2: Generate migration**

```bash
npx prisma migrate dev --name add_human_answer_v1
```

Expected: migration succeeds and Prisma client regenerates.

- [ ] **Step 3: Commit persistence model**

```bash
git add prisma/schema.prisma prisma/migrations
git commit -m "feat: add human answer persistence models"
```

### Task 3: Add validation and domain services

**Files:**
- Create: `src/features/questions/types.ts`
- Create: `src/features/questions/validation.ts`
- Create: `src/features/questions/service.ts`
- Create: `src/features/moderation/sanitize.ts`
- Test: `tests/api/questions.test.ts`

- [ ] **Step 1: Define shared types**

Create `src/features/questions/types.ts`:

```ts
export const QUESTION_SCENARIOS = [
  "不知道怎么回",
  "对方变冷",
  "吵架修复",
  "聊天复盘",
  "其他",
] as const;

export type QuestionScenario = (typeof QUESTION_SCENARIOS)[number];

export type PublicAnswer = {
  id: string;
  type: "ai" | "human";
  content: string;
  status: "pending" | "visible" | "selected" | "reported" | "hidden";
  createdAt: string;
};

export type PublicQuestion = {
  id: string;
  scenario: string;
  content: string;
  status: string;
  expiresAt: string;
  selectedAnswerId: string | null;
};
```

- [ ] **Step 2: Define validation schemas**

Create `src/features/questions/validation.ts`:

```ts
import { z } from "zod";
import { QUESTION_SCENARIOS } from "./types";

export const createQuestionSchema = z.object({
  scenario: z.enum(QUESTION_SCENARIOS),
  content: z.string().trim().min(10).max(5000),
  imageUrl: z.string().url().nullable().optional(),
  ocrText: z.string().trim().max(10000).nullable().optional(),
});

export const submitHumanAnswerSchema = z.object({
  questionId: z.string().min(1),
  content: z.string().trim().min(10).max(1000),
});

export const selectAnswerSchema = z.object({
  answerId: z.string().min(1),
});

export const moderationReportSchema = z.object({
  questionId: z.string().min(1),
  answerId: z.string().min(1).nullable().optional(),
  reason: z.enum(["unmasked_private_info", "low_quality_answer", "unsafe_content"]),
});
```

- [ ] **Step 3: Add public sanitization**

Create `src/features/moderation/sanitize.ts`:

```ts
const PRIVATE_PATTERNS = [
  /1[3-9]\d{9}/g,
  /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
  /(微信|wechat|wx|VX)[:：]?\s*[a-zA-Z0-9_-]{5,}/gi,
];

export function redactPrivateText(input: string): string {
  return PRIVATE_PATTERNS.reduce(
    (text, pattern) => text.replace(pattern, "[已打码]"),
    input,
  );
}

export function canDistributeToHumanTask(question: {
  status: string;
  imageUrl: string | null;
  maskedImageUrl: string | null;
  reports?: Array<{ reason: string }>;
}): boolean {
  if (question.status === "reported" || question.status === "closed" || question.status === "resolved") return false;
  if (question.imageUrl && !question.maskedImageUrl) return false;
  if (question.reports?.some((report) => report.reason === "unmasked_private_info")) return false;
  return true;
}
```

- [ ] **Step 4: Implement service functions**

Create `src/features/questions/service.ts` with functions named:

```ts
export async function createQuestion(input: {
  askerId: string;
  scenario: string;
  content: string;
  imageUrl?: string | null;
  ocrText?: string | null;
}) { /* use prisma.question.create */ }

export async function getQuestionResult(input: { questionId: string; viewerId: string }) { /* return sanitized question and visible answers */ }

export async function listHumanTasks(input: { answererId: string }) { /* return privacy-safe unanswered tasks */ }

export async function submitHumanAnswer(input: { questionId: string; answererId: string; content: string }) { /* create answer and +1 reward in a transaction */ }

export async function selectBestAnswer(input: { questionId: string; askerId: string; answerId: string }) { /* resolve once and award +5 for human answer */ }
```

Implementation rules:
- Use the app's existing Prisma client import path.
- Each write that affects rewards must use a database transaction.
- Throw typed errors or HTTP-safe errors for invalid ownership, duplicate answer, closed task, and duplicate selection.

- [ ] **Step 5: Add focused tests for validation and service errors**

Create tests covering:
- Question content shorter than 10 characters fails.
- Duplicate human answer for the same `questionId` and `answererId` fails.
- Selecting a second best answer fails.
- Reported questions are excluded from human tasks.

Run:

```bash
npm test -- tests/api/questions.test.ts
```

Expected: tests pass.

- [ ] **Step 6: Commit domain layer**

```bash
git add src/features tests/api/questions.test.ts
git commit -m "feat: add human answer domain services"
```

### Task 4: Implement backend APIs and AI persistence

**Files:**
- Create: `src/features/questions/ai-answer.ts`
- Create or modify: API route files listed in File Structure
- Test: `tests/api/questions.test.ts`, `tests/api/human-answer.test.ts`

- [ ] **Step 1: Add AI answer adapter**

Create `src/features/questions/ai-answer.ts`:

```ts
export async function generateAiAnswerForQuestion(input: {
  questionId: string;
  scenario: string;
  content: string;
  ocrText?: string | null;
}) {
  const prompt = [
    `场景：${input.scenario}`,
    `用户问题：${input.content}`,
    input.ocrText ? `OCR 摘要：${input.ocrText}` : "",
    "请输出：当前关系判断、对方信号、用户主要风险、下一步策略、可复制回复、安全边界提醒。",
    "不要承诺保证复合、保证拿下，不要诱导骚扰、控制、跟踪、威胁或持续打扰明确拒绝的人。",
  ].filter(Boolean).join("\n\n");

  return { prompt };
}
```

Connect this adapter to the app's existing `/api/chat` implementation or direct model client in the route/service layer. Store the final text as `Answer(type=ai,status=visible,answererId="system_ai")`.

- [ ] **Step 2: Implement route handlers**

Each route handler must:
- Read current user from the app's existing auth helper.
- Validate request body with schemas from `validation.ts`.
- Call exactly one domain service function.
- Return JSON with the API contract above.
- Return `400` for validation errors, `401` for missing auth, `403` for ownership violations, `409` for duplicate/closed state conflicts, and `500` for unexpected failures.

- [ ] **Step 3: API tests**

Add tests for:
- `POST /api/questions` creates `Question` and AI `Answer`.
- `GET /api/human/tasks` returns the new task.
- `POST /api/human/answers` creates a human `Answer` and `RewardLedger(+1)`.
- `POST /api/questions/:id/select-answer` resolves once and creates `RewardLedger(+5)` for a human answer.
- `POST /api/moderation/report` pauses task distribution.

Run:

```bash
npm test -- tests/api/questions.test.ts tests/api/human-answer.test.ts
```

Expected: all API/domain tests pass.

- [ ] **Step 4: Commit backend APIs**

```bash
git add src/app/api src/features/questions/ai-answer.ts tests/api
git commit -m "feat: add human answer API endpoints"
```

### Task 5: Implement ask flow and result page

**Files:**
- Modify: `src/app/page.tsx` or current homepage component
- Create: `src/components/questions/AskForm.tsx`
- Create: `src/app/questions/[id]/page.tsx`
- Create: `src/components/questions/QuestionResult.tsx`

- [ ] **Step 1: Build ask form**

`AskForm.tsx` must include:
- Scenario buttons for the five V1 scenarios.
- Textarea with minimum 10-character validation.
- Screenshot upload entry with privacy warning visible before submit.
- Submit button that calls `POST /api/questions`.
- Redirect to `/questions/:id` on success.

- [ ] **Step 2: Make homepage ask-first**

Replace or move the current marketing-first hero so the first screen contains the ask form and the AI/human mechanism preview from the PRD.

- [ ] **Step 3: Build result page**

`QuestionResult.tsx` must:
- Fetch `GET /api/questions/:id` on load.
- Poll every 5 seconds while human answer window is open.
- Show AI answer card immediately when available.
- Show waiting state for human answers.
- Show human answer cards when available.
- Show `选择最佳回答` only to the asker and only before the question is resolved.
- Call `POST /api/questions/:id/select-answer` and update UI to resolved state.

- [ ] **Step 4: Frontend tests**

Run the app's frontend test suite:

```bash
npm test -- AskForm QuestionResult
```

Expected: component tests pass for validation, submit success, submit error, answer selection, and resolved state.

- [ ] **Step 5: Commit ask/result UI**

```bash
git add src/app src/components/questions
git commit -m "feat: add question ask flow and result page"
```

### Task 6: Replace human desk mock data with real APIs

**Files:**
- Create or modify: `src/app/human-answer/page.tsx`
- Create: `src/components/human-answer/HumanAnswerDesk.tsx`
- Optionally port styles from: `human-answer.css`

- [ ] **Step 1: Port prototype layout**

Preserve these behaviors from `human-answer.html` and `human-answer.js`:
- Task queue with `全部 / 可答 / 即将超时` filters.
- Current task panel with masked context, OCR summary, countdown, and answer editor.
- Minimum 10-character answer validation.
- Enter-to-submit behavior if that convention remains acceptable for the app.
- Reward panel and report button.

- [ ] **Step 2: Load real tasks**

Replace local `tasks = [...]` with fetch logic:

```ts
async function loadHumanTasks() {
  const response = await fetch("/api/human/tasks", { cache: "no-store" });
  if (!response.ok) throw new Error("任务池加载失败");
  return response.json() as Promise<{ tasks: Array<HumanTask> }>;
}
```

- [ ] **Step 3: Submit real answers**

Replace local `state.submitted.add(task.id)` with `POST /api/human/answers`; on success update the selected task status to `submitted`, update reward balance from response, and reload tasks.

- [ ] **Step 4: Wire report button**

Call `POST /api/moderation/report` with `reason="unmasked_private_info"`; on success remove the task from the current queue and show a toast saying the task has paused distribution.

- [ ] **Step 5: Commit human desk integration**

```bash
git add src/app/human-answer src/components/human-answer
git commit -m "feat: connect human answer desk to APIs"
```

### Task 7: Add rewards/account integration and abuse guards

**Files:**
- Create or modify: `src/app/api/rewards/me/route.ts`
- Modify: existing account page or create reward summary component
- Modify: `src/features/questions/service.ts`
- Test: `tests/api/human-answer.test.ts`

- [ ] **Step 1: Implement reward summary**

`GET /api/rewards/me` returns:

```json
{
  "balance": 13,
  "todaySubmitCount": 2,
  "todaySelectedCount": 1,
  "ledger": [
    { "delta": 1, "reason": "submit_answer", "questionId": "q_123", "createdAt": "2026-07-07T04:10:00.000Z" },
    { "delta": 5, "reason": "selected_answer", "questionId": "q_123", "createdAt": "2026-07-07T04:20:00.000Z" }
  ]
}
```

- [ ] **Step 2: Add V1 abuse limits**

In `submitHumanAnswer`, enforce:
- One answer per user per question.
- Maximum 50 participation rewards per user per day.
- No reward for answers hidden or reported before ledger creation.

- [ ] **Step 3: Add tests**

Cover:
- Daily cap blocks the 51st reward.
- Duplicate answer does not create duplicate reward.
- Selecting a human answer creates exactly one +5 ledger row.

- [ ] **Step 4: Commit rewards integration**

```bash
git add src/app/api/rewards src/features/questions/service.ts tests/api/human-answer.test.ts
git commit -m "feat: add reward ledger integration"
```

### Task 8: Complete privacy, reporting, and status transitions

**Files:**
- Modify: `src/features/moderation/sanitize.ts`
- Modify: `src/features/questions/service.ts`
- Modify: `src/app/api/moderation/report/route.ts`
- Test: `tests/api/human-answer.test.ts`

- [ ] **Step 1: Ensure human tasks never expose raw identity**

`listHumanTasks` response must not include:
- `askerId`
- raw `imageUrl`
- original nickname/avatar/contact fields
- unredacted phone, email, WeChat ID, QR code URL, or address text

- [ ] **Step 2: Implement report pause**

When `reason="unmasked_private_info"`:
- Create `ModerationReport`.
- Set `Question.status = "reported"` or equivalent paused state.
- Exclude the question from `GET /api/human/tasks`.

- [ ] **Step 3: Implement timeout logic**

A task is closed to human submission when `expiresAt <= now`. Result page still shows AI answer and any already visible human answers.

- [ ] **Step 4: Commit privacy/reporting logic**

```bash
git add src/features src/app/api/moderation tests/api/human-answer.test.ts
git commit -m "feat: enforce privacy and reporting rules"
```

### Task 9: Add end-to-end tests

**Files:**
- Create: `tests/e2e/lovetrain-human-answer.spec.ts`
- Modify: `docs/v1-human-answer-test-record.md`

- [ ] **Step 1: Write E2E chain**

The test must:
1. Log in or seed test user A as asker.
2. Submit a question from homepage ask form.
3. Assert redirected result URL is `/questions/:id`.
4. Assert AI answer state appears.
5. Log in or seed test user B as human answerer.
6. Open `/human-answer` and find A's question.
7. Submit a valid human answer.
8. Return as user A to result page and assert the human answer is visible.
9. Select B's answer.
10. Assert B's reward ledger contains +1 and +5 records.

- [ ] **Step 2: Run E2E**

```bash
npm run test:e2e -- tests/e2e/lovetrain-human-answer.spec.ts
```

Expected: the full chain passes in local test environment.

- [ ] **Step 3: Update test record**

Replace the initial pending verification lines in `docs/v1-human-answer-test-record.md` with actual command output summaries, tester, date, environment, and pass/fail status.

- [ ] **Step 4: Commit tests and evidence**

```bash
git add tests/e2e/lovetrain-human-answer.spec.ts docs/v1-human-answer-test-record.md
git commit -m "test: cover LoveTrain human answer end-to-end flow"
```

### Task 10: Release readiness

**Files:**
- Modify: deployment environment documentation
- Modify: `docs/v1-human-answer-test-record.md`

- [ ] **Step 1: Verify environment variables**

Required runtime capabilities:
- Database URL for persisted `Question`, `Answer`, `RewardLedger`, `ModerationReport` data.
- AI generation credentials or access to existing `/api/chat` implementation.
- Auth/session configuration for asker and human answerer roles.
- Storage credentials if screenshot upload is enabled.

- [ ] **Step 2: Run full verification**

```bash
npm run lint
npm test
npm run test:e2e
npm run build
```

Expected: all commands exit with status 0.

- [ ] **Step 3: Manual smoke test on preview deployment**

Perform the same chain from the PRD acceptance criteria:
- Website question creates backend `Question`.
- Human desk sees the question through `GET /api/human/tasks`.
- Human answer creates `Answer(type=human)`.
- Asker result page shows AI and human answers under the same question.
- Selecting human answer creates +5 reward ledger.
- Refresh keeps all states.

- [ ] **Step 4: Commit release record**

```bash
git add docs/v1-human-answer-test-record.md
git commit -m "docs: record human answer V1 release verification"
```

## Milestone Schedule

- Day 1: Target repo baseline, schema, validation, service tests.
- Day 2: Backend APIs, AI answer persistence, reward transactions.
- Day 3: Homepage ask form and result page.
- Day 4: Human answer desk API integration and reporting.
- Day 5: E2E tests, privacy checks, preview deployment, release record.

## Acceptance Checklist

- [ ] `website-product-spec.md` V1 P0 items are implemented in code.
- [ ] `human-answer.js` mock data is no longer the source of task truth in production.
- [ ] New website question creates a persisted `Question`.
- [ ] AI and human answers are stored under the same `questionId`.
- [ ] Human answer submission writes an `Answer(type=human)` and `RewardLedger(+1)`.
- [ ] Best-answer selection writes `RewardLedger(+5)` for selected human answer.
- [ ] Reported unmasked content stops appearing in the human task pool.
- [ ] Refreshing result page preserves question, answers, selected state, and reward state.
- [ ] API tests and E2E tests pass.
- [ ] `docs/v1-human-answer-test-record.md` contains final verification evidence.

## Self-Review

- Spec coverage: P0/P1 requirements from `website-product-spec.md` are mapped to persistence, APIs, ask UI, result UI, human answer desk, rewards, privacy/reporting, and E2E tests.
- Placeholder scan: no implementation step relies on unspecified future behavior; the only assumption is the production app stack, and the plan preserves concrete contracts if the stack differs.
- Type consistency: API field names match the PRD model names: `Question`, `Answer`, `RewardLedger`, `questionId`, `answerId`, `status`, `expiresAt`, and `selectedAnswerId`.
- Scope control: P2 items such as leaderboard, levels, quality scoring, public FAQ, and full admin UI are intentionally excluded from V1 implementation tasks.
