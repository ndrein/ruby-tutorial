# Branching Strategy — Ruby Learning Platform

**Feature**: ruby-learning-platform
**Date**: 2026-03-09
**Status**: Approved
**Strategy**: Trunk-Based Development

---

## Strategy Selection

**Trunk-Based Development** (TBD) is selected. Single `main` branch. All work lands on `main` within one day. No long-lived feature branches. No `develop`, `staging`, or `release` branches.

### Why TBD for this project

| Factor | Evidence | TBD fit |
|--------|----------|---------|
| Team size | 1 developer | Optimal — merge conflict overhead from branches is pure waste |
| Release cadence | On-demand (deploy when ready) | Optimal — every commit to `main` is releasable |
| Test maturity | RSpec + Brakeman + SimpleCov + mutation testing | Required — TBD needs robust CI to be safe |
| Feature risk | Personal tool, no external users | Low blast radius — short-lived branches have no benefit |

### Rejected alternatives

**Alternative 1: GitHub Flow (PR-always)**
- What: Every change goes through a pull request, even solo work.
- Why rejected: PR overhead (open PR, wait for CI, merge) with no reviewer adds friction without benefit. For a solo developer on a personal tool, direct-to-main with CI gates achieves the same safety with less ceremony.

**Alternative 2: GitFlow**
- What: `main` + `develop` + `feature/*` + `release/*` + `hotfix/*`.
- Why rejected: Five branch types for one developer is over-engineered. GitFlow was designed for teams with separate release managers. Not applicable to a personal tool with on-demand deployment.

---

## Rules

### Core rules

1. `main` is always releasable. Every commit that passes CI is deployable to production.
2. Feature branches are short-lived: opened and merged within 1 calendar day. If not mergeable in 1 day, the branch is too large — split it.
3. Direct push to `main` is permitted for trivial changes (documentation, config) if the developer is certain CI gates will pass.
4. For any non-trivial change (domain logic, migrations, new endpoints), open a short-lived branch and push via PR to ensure CI runs on the branch before merge.
5. No merging with failing CI. The pipeline is the final arbiter.
6. One feature per branch. No bundled changes across multiple features.

### Branch lifecycle

```
main ────────────────────────────────────────────────────► always releasable
  │                │                │
  └─ feat/sm2-algo ┘                │
    (< 1 day)                       │
                    └─ fix/health-check ┘
                      (< 4 hours)
```

### Branch naming convention

| Pattern | Use |
|---------|-----|
| `feat/{short-description}` | New feature work |
| `fix/{short-description}` | Bug fix |
| `chore/{short-description}` | Infrastructure, tooling, dependency updates |
| `docs/{short-description}` | Documentation only |

Examples:
- `feat/sm2-review-scheduler`
- `fix/prerequisite-graph-cycle-detection`
- `chore/update-rubocop-config`
- `docs/add-api-health-endpoint`

Short-description: lowercase, hyphens, no underscores, max 40 characters.

---

## Commit Conventions

Commits follow the Conventional Commits specification (https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or behavior |
| `fix` | Bug fix |
| `test` | Adding or updating tests (no production code change) |
| `refactor` | Code restructuring without behavior change |
| `chore` | Build, tooling, dependency updates |
| `docs` | Documentation only |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |

### Scopes (aligned to domain modules)

| Scope | Module |
|-------|--------|
| `sm2` | SM-2 domain (algorithm, scheduler, queue) |
| `curriculum` | Curriculum domain (lesson tree, prerequisite graph) |
| `session` | Session domain (planner, state) |
| `progress` | Progress domain (tracker, retention) |
| `exercise` | Exercise domain (types, evaluation) |
| `web` | Rails controllers, views, Turbo/Stimulus |
| `db` | Migrations, schema |
| `ci` | GitHub Actions workflows |
| `docker` | Dockerfile, Compose files |
| `otel` | OpenTelemetry instrumentation |

### Examples

```
feat(sm2): implement SM2Algorithm pure function

Implements stateless SM-2 computation: inputs current_interval,
ease_factor, result; outputs new_interval, new_ease_factor,
next_review_date.

No ActiveRecord dependencies — fully testable without database.
```

```
fix(curriculum): enforce acyclicity check on prerequisite graph load

PrerequisiteGraph.load now raises PrerequisiteGraph::CycleError
if prerequisites.yml contains a cycle. Previously silently
produced an infinite loop in LessonUnlocker.
```

```
chore(ci): add bundler-audit CVE check to CI pipeline
```

---

## CI Triggers

### On push to main

Triggers: `ci.yml` full pipeline
- lint-audit (RuboCop, Brakeman, bundler-audit)
- unit-tests (domain layer, no DB)
- integration-tests (full RSpec + PostgreSQL + Redis)
- mutation-tests (scoped to modified domain files, kill rate >= 80%)

### On pull request targeting main

Triggers: `ci.yml` — all jobs except `mutation-tests`

Mutation testing runs only on `main` (post-merge) because:
- It requires identifying "modified files" relative to `HEAD~1`, which is well-defined only on main after merge.
- It is the final quality gate, not a merge gate — keeping it post-merge avoids blocking PRs on expensive computation.

### On workflow_dispatch (manual)

Triggers: `deploy.yml` — deploys to self-hosted production.

---

## Branch Protection Configuration

Configure in GitHub: Settings > Branches > Add rule > Branch name pattern: `main`

```yaml
# Branch protection for `main`

required_status_checks:
  strict: true  # Require branch to be up to date before merge
  contexts:
    - "Lint & Security Audit"
    - "Unit Tests (Domain)"
    - "Integration Tests"
    # Note: mutation-tests is NOT a merge gate (runs post-merge on main)

enforce_admins: false
  # Solo developer: admin bypass allowed for hotfixes

required_pull_request_reviews: null
  # Solo developer: PR reviews not required. CI gates provide the safety net.

restrictions: null
  # No push restrictions — any authenticated push allowed (solo dev)

allow_force_pushes: false
  # Never force push to main — history is immutable

allow_deletions: false
  # Main cannot be deleted

required_linear_history: true
  # Enforce squash or rebase merges — no merge commits on main
```

Note on `required_linear_history`: When merging a feature branch, use squash merge to produce a single commit on `main` with a clean Conventional Commit message. Alternatively, rebase the feature branch before merge.

---

## Release and Versioning

There are no scheduled releases. Deployment is on-demand via `workflow_dispatch`.

Version tagging is optional but recommended for meaningful milestones (feature complete, breaking migration, etc.).

### Tagging convention

```bash
# Semantic versioning: MAJOR.MINOR.PATCH
git tag -a v1.0.0 -m "feat: initial ruby learning platform release"
git push origin v1.0.0
```

| Version bump | When |
|-------------|------|
| PATCH (0.0.X) | Bug fix, internal refactor, documentation |
| MINOR (0.X.0) | New feature, new domain capability |
| MAJOR (X.0.0) | Breaking schema change, major architecture change |

Tags are informational only — they do not auto-trigger deployment. Deployment is always manual.

---

## Feature Flags

Feature flags manage incomplete work on `main` without feature branches exceeding 1 day.

For this Rails stack, use environment variables as simple feature flags:

```ruby
# config/feature_flags.rb
module FeatureFlags
  # Worker / Sidekiq features (post-MVP)
  SIDEKIQ_ENABLED = ENV.fetch("FEATURE_SIDEKIQ", "false") == "true"
  EMAIL_DIGEST_ENABLED = ENV.fetch("FEATURE_EMAIL_DIGEST", "false") == "true"
end
```

```ruby
# Usage in domain service
if FeatureFlags::EMAIL_DIGEST_ENABLED
  EmailDigestJob.perform_later(user_id: user.id)
end
```

This allows Sidekiq infrastructure code to land on `main` (commented out in Compose) while the feature flag disables it until the job is implemented and ready.

---

## Pre-commit Hooks (Optional, Recommended)

Install pre-commit hooks locally to catch issues before push, reducing failed CI runs:

```bash
# Install lefthook (lightweight Git hooks manager)
gem install lefthook

# lefthook.yml
pre-commit:
  commands:
    rubocop:
      glob: "*.rb"
      run: bundle exec rubocop --autocorrect-all {staged_files}
    brakeman:
      run: bundle exec brakeman --quiet
```

Pre-commit hooks are a developer convenience — they do not replace CI. CI is the authoritative gate.

---

## Workflow Summary

```
Developer workflow (trunk-based, solo):

1. Pull latest main
   git pull origin main

2a. Trivial change (docs, config, obvious fix):
   git add -p
   git commit -m "fix(ci): correct health check timeout"
   git push origin main
   → CI runs → green → done

2b. Non-trivial change (domain logic, migration):
   git checkout -b feat/sm2-carry-over
   # ... work, commit locally, keep branch < 1 day ...
   git push origin feat/sm2-carry-over
   # Open PR → CI runs on branch → merge → CI runs on main → mutation tests run
   git checkout main && git pull
   git branch -d feat/sm2-carry-over

3. Deploy when ready:
   GitHub Actions → Actions tab → Deploy to Production → Run workflow
```
