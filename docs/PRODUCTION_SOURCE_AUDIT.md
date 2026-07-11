# LoveTrain Production Website Source Audit

Audit date: 2026-07-11

## Why This Audit Exists

The PRD requires the Human Answer V1 chain to work on the real LoveTrain website, not only in a substitute backend or local prototype. This audit checks whether the repositories currently available in the workspace are the source of the deployed Vercel website.

## Sites Checked

### PRD deployment URL

`https://love-train-v12-cz63n5bqu-flyxqc1s-projects.vercel.app/`

Observed:

- HTTP 200 from Vercel.
- Next.js application with build ID `xyEzhVQvdyYLd5EMB_6mr`.
- Title: `爱之列车 — 情感导师`.
- Client bundle calls `/api/verify`, `/api/auth/me`, and `/api/chat`.
- This deployment does not match the current static production alias described below.

### Current Vercel alias and custom domain

- `https://love-train-v12.vercel.app/`
- `https://r2i84a.chat/`

Observed:

- Both domains serve the same current static website.
- `/human-answer` is a static Human Answer desk.
- The deployed `/human-answer.js` SHA-256 is:
  - `b685bccfc4e0630f6de4e36d51006e054c012782c79c2bed298bd073fb1e6812`
- The local PRD repository's `human-answer.js` has the exact same SHA-256.
- The matching script starts with `const tasks = [` and uses local mock tasks/rewards.
- `/api/questions`, `/api/human/tasks`, and `/api/chat` return HTTP 404.
- The deployed homepage differs from this repository's `index.html` and references files not present here, including `styles.css`, `script.js`, QR assets, and additional pages.

## Repository and Access Findings

- `hotcoffeeshake/love-train-human-answer-prd`
  - Available and writable.
  - Contains the PRD and a subset of the static production source.
  - Does not contain the complete currently deployed website.
- `hotcoffeeshake/love-train-mp`
  - Available read-only to both configured GitHub accounts.
  - Is a Fastify backend + WeChat Mini Program repository.
  - The feature branch contains a complete local AI + human answer backend and minimal Fastify-served web flow.
  - It is not the source currently serving `love-train-v12.vercel.app` or `r2i84a.chat`.
- GitHub user `flyxqc1`, inferred from the Vercel team slug, has no public repositories.
- GitHub code/repository searches did not find the deployed website source.
- The Vercel project API requires an authentication token; no Vercel CLI/token or local Vercel auth state is available in this environment.
- The public Vercel project page exposes a `Connect Git` control, but unauthenticated project data calls fail, so the Git connection cannot be conclusively inspected.

## Conclusion

The real production website source repository or source archive has **not** been obtained.

`love-train-mp` is a valid implementation target for the backend/domain work and provides strong local acceptance evidence, but it must not be described as the source of the current Vercel website. Production acceptance remains unproven until the real website source or Vercel project access is provided and the frontend is connected to the implemented API.

## Required Handoff to Finish V1

Provide at least one of the following:

1. The local path, Git URL, or source archive used for the latest `love-train-v12` Vercel deployment.
2. Authenticated Vercel project access that permits source/deployment inspection and a preview deployment.
3. An explicit decision to promote one available repository into the canonical website source:
   - upgrade this PRD repository into the complete website, or
   - deploy the Fastify web flow from `love-train-mp` as the canonical site.

Also required:

- Write access to `hotcoffeeshake/love-train-mp`, or approval to use a fork/PR workflow.
- A browser-capable session for the final DOM/manual acceptance chain.
- A deployed database and AI-provider configuration for `BASE_URL` smoke.

## Reproduce the Public Checks

Run from this repository:

```bash
bash docs/scripts/audit-production-source.sh
```

The script is read-only. It downloads temporary public responses, compares the mock script hash, probes required API routes, and removes its temporary directory on exit.
