# Branching Strategy — Ruby Learning Platform

**Feature ID**: ruby-learning-platform
**Phase**: DEVOPS
**Date**: 2026-03-10
**Status**: Accepted

---

## Overview

Trunk-Based Development. One main branch (`main`). Short-lived feature branches (< 1 day). No release branches, no long-lived environment branches. `main` is always deployable.

---

## Trunk-Based Development Rules

### Core Invariants

1. **`main` is always deployable.** Every commit on `main` must pass CI and be deployable to production. Never commit broken code directly to `main`.

2. **Feature branches live less than one day.** If a feature branch lives longer than 24 hours, it accumulates merge risk and conflicts with the trunk-based model. Break the work into smaller increments instead.

3. **Direct commits to `main` are allowed only for trivial changes.** Acceptable: documentation updates, config file changes, single-line fixes with no logic impact. Any change touching application code, tests, or migrations must go through a feature branch with CI passing before merge.

4. **No long-lived branches.** There are no `develop`, `staging`, `release/*`, or `hotfix/*` long-lived branches. All work flows through `main`.

5. **Rebase, don't merge.** Feature branches should be rebased on `main` before merging to produce a clean linear history. Merge commits are acceptable for PRs if the team prefers the default GitHub behavior, but linear history via squash-merge is preferred.

---

## Branch Naming Convention

| Branch type | Pattern | Example | Max lifetime |
|-------------|---------|---------|-------------|
| Feature | `feat/<short-description>` | `feat/sm2-engine` | < 1 day |
| Bug fix | `fix/<short-description>` | `fix/session-cap-boundary` | < 1 day |
| Refactoring | `refactor/<short-description>` | `refactor/queue-builder` | < 1 day |
| Chore / tooling | `chore/<short-description>` | `chore/update-ruby-4-0` | < 1 day |
| Test-only | `test/<short-description>` | `test/sm2-edge-cases` | < 1 day |
| Main | `main` | — | Permanent |

Branch names must be lowercase with hyphens. No underscores, no uppercase, no ticket numbers (no ticketing system for this personal project).

---

## CI Trigger Rules

| Event | Jobs triggered | Deploy? |
|-------|---------------|---------|
| Push to `main` | test-unit + test-integration + test-system (parallel) | Yes, if all pass |
| Push to any feature branch | test-unit + test-integration + test-system (parallel) | No |
| Pull request targeting `main` | test-unit + test-integration + test-system (parallel) | No |
| Push to `main` after PR merge | test-unit + test-integration + test-system (parallel) | Yes, if all pass |

The deploy job in CI requires `github.ref == 'refs/heads/main'` and `github.event_name == 'push'` — it does not trigger on pull_request events even if the PR targets main.

---

## Branch Protection Rules for GitHub

Configure at: Repository Settings → Branches → Branch protection rules → Add rule

```
Branch name pattern: main

[x] Require a pull request before merging
    Required approvals: 0
    (Single-developer project — approval gates are impractical)

[x] Require status checks to pass before merging
    Required status checks:
      - Tests: Unit & Service       (job: test-unit)
      - Tests: Integration          (job: test-integration)
      - Tests: System / Acceptance  (job: test-system)
    [x] Require branches to be up to date before merging

[x] Require conversation resolution before merging
    (If PRs are used with comments)

[ ] Require signed commits
    (Optional for personal project)

[x] Do not allow bypassing the above settings
    (Even repository administrators must pass CI)

[x] Restrict who can push to matching branches
    Push to main allowed: repository owner only

[ ] Allow force pushes   — DISABLED
[ ] Allow deletions      — DISABLED
```

**Note on required approvals**: Set to 0 because this is a single-developer personal project. The value of the protection rule comes from the mandatory CI gate, not peer review. If a second contributor is added, increase to 1.

---

## Commit Message Convention

Conventional Commits format (https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or user-visible behavior |
| `fix` | Bug fix |
| `test` | Adding or modifying tests only |
| `refactor` | Code change that is not a feature or bug fix |
| `chore` | Dependency updates, tooling, config |
| `docs` | Documentation only |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |

### Scope (optional but encouraged)

Use the component name: `sm2`, `queue-builder`, `session`, `auth`, `email`, `jobs`, `ci`, `db`.

### Examples

```
feat(sm2): implement SM2Engine pure function with all quality scores
fix(session): enforce 900s cap on server side after clock skew
test(queue-builder): add edge case for empty review set
refactor(session-tracker): extract StreakUpdater into separate service
chore: bump Ruby to 4.0.1 patch release
ci: add Selenium Chrome headless step to system test job
docs: update Fly.io deploy instructions in platform-architecture.md
```

### Breaking Changes

If a commit introduces a breaking change (schema migration that requires data migration, API contract change), mark it:

```
feat(db)!: add unique index on daily_queues (user_id, queue_date)

BREAKING CHANGE: requires migration 007 to run before deploy.
Release command handles this automatically via db:migrate.
```

---

## Tag Strategy

Production deploys are automatically tagged by the CI deploy job.

### Tag Format

```
v{YYYY-MM-DD}-{short-sha}
```

Examples:
- `v2026-03-10-a3f8b2c`
- `v2026-03-11-def4567`

### Automated Tagging in CI

The deploy job creates and pushes the tag after a successful `flyctl deploy`:

```yaml
- name: Tag production deploy
  run: |
    TAG="v$(date -u +%Y-%m-%d)-${GITHUB_SHA::7}"
    git tag "$TAG"
    git push origin "$TAG"
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Tag Use Cases

- **Identifying what is in production**: `git log v2026-03-10-a3f8b2c..HEAD` shows commits not yet deployed.
- **Rollback reference**: `fly deploy --image registry.fly.io/<APP_NAME>:<tag>` deploys a specific tagged build.
- **Historical reference**: Find what code was running on a given date.

### No Semantic Versioning

Semantic versioning (v1.2.3) is not used. This is a personal tool without public API contracts or library consumers. Date-based tags provide sufficient traceability.

---

## Workflow: Feature Development Lifecycle

```
1. Pull latest main
   git checkout main && git pull origin main

2. Create short-lived feature branch
   git checkout -b feat/sm2-engine

3. Implement feature with commits (conventional commits format)
   git commit -m "feat(sm2): implement SM2Engine core algorithm"
   git commit -m "test(sm2): add full quality score coverage"

4. Push branch and open PR (or push directly if trivial)
   git push -u origin feat/sm2-engine

5. CI runs on branch push — verify all tests pass in GitHub Actions

6. Merge to main (squash or regular merge — CI must be green)
   GitHub PR merge button (or git merge --no-ff for local)

7. CI runs on main push — deploy triggered automatically

8. Verify deploy success in CI log and Fly dashboard

9. Delete feature branch
   git branch -d feat/sm2-engine
   git push origin --delete feat/sm2-engine
```

---

## What Is Explicitly Not Used

| Pattern | Reason excluded |
|---------|----------------|
| GitFlow (develop/release/hotfix branches) | Over-engineered for single-developer project; release branches add no value when main is always deployable |
| GitHub Flow with long-lived feature branches | Contradicts trunk-based principle; long branches accumulate merge risk |
| Release branches (`release/v1.x`) | No versioned releases; continuous deployment makes release branches redundant |
| Environment branches (`staging`, `production`) | Single environment; environment config is via Fly.io secrets, not branches |
| Monorepo trunk with feature flags | Feature flags are useful at scale; for a 25-lesson personal tool they add unnecessary complexity |
