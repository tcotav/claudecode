# PR Describe Skill

Write a PR description that a reviewer can use to evaluate the changes. Covers what changed, affected environments, deployment risk, and validation done.

---

## Step 1: Gather Context

Run these in parallel to understand what's in the branch:

- `git log main..HEAD --oneline` — list commits on this branch
- `git diff main...HEAD --stat` — files changed and change volume
- `git diff main...HEAD` — full diff for content analysis
- `git branch --show-current` — branch name (may hint at ticket/feature)

Also check for context clues:
- Look for `*.tf`, `helm/`, `k8s/`, `.github/workflows/`, `Dockerfile` in changed files — these affect environment/risk assessment
- Look for migration files (`migrations/`, `*.sql`, `*_migration.*`) — these are high-risk deployment signals
- Look for config file changes (`*.yaml`, `*.json`, `*.toml`, `.env*`) — may affect environments

---

## Step 2: Analyze and Classify

From the diff, determine:

**What changed:**
- Identify the logical change units (e.g., "added retry logic", "updated DB schema", "refactored auth middleware")
- Group related file changes together rather than listing files

**Environments affected:**
- `local` — always affected if code changes
- `staging` / `dev` — if CI/CD pipeline files changed, or config differences exist
- `production` — default assumption for any merged code; flag explicitly if infra/config changes narrow or widen scope
- If no environment signal exists, default to: "All environments (local, staging, production)"

**Deployment risk:**
Assign one of:
- `Low` — logic-only changes, no schema/config/infra, tests pass, no new dependencies
- `Medium` — new dependencies, config changes, or changes to shared utilities/middleware
- `High` — DB migrations, infra changes, auth/permission changes, breaking API contracts, changes to CI/CD pipelines

Explain *why* the risk level was chosen in 1–2 sentences.

**Validation done:**
Scan commit messages and diff for signals:
- Test files added or modified → note what was tested
- CI workflow changes → note if pipeline was updated
- Manual testing references in commit messages → include them
- If no validation signals found, note: "No automated tests found for these changes — reviewer should verify test coverage."

---

## Step 3: Draft the PR Description

Produce a description in this format:

```markdown
## What Changed
<2–5 bullet points describing logical changes, not file names>

## Environments Affected
<list environments; note any that are specifically included or excluded>

## Deployment Risk
**Level:** Low / Medium / High

<1–2 sentences explaining why>

**Checklist:**
- [ ] DB migrations required
- [ ] Config/env var changes required
- [ ] Dependent services need updating
- [ ] Feature flag needed

(Check any that apply based on the diff)

## Validation
<bullet points: automated tests added/updated, manual steps taken, CI changes>
```

---

## Step 4: Deliver or Apply

Present the draft to the user.

Then ask:
> "Would you like to use this as your PR description? I can open the PR with `gh pr create`, update an existing PR with `gh pr edit`, or just copy it to your clipboard."

- **Create PR**: run `gh pr create --title "<derived title>" --body "$(cat <<'EOF' ... EOF)"`
- **Edit existing PR**: run `gh pr edit --body "$(cat <<'EOF' ... EOF)"`
- **Clipboard only**: output the raw markdown block for the user to copy

If creating or editing a PR, return the PR URL when done.

---

## Safety

- **NEVER** push branches or force-push
- **NEVER** merge or close PRs
- **NEVER** modify files — this skill is read-only except for `gh pr create/edit`
