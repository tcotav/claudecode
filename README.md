# Claude Code Skills

A collection of custom skills for [Claude Code](https://claude.ai/code). Each skill is a markdown file that defines behavior Claude follows when invoked via the `Skill` tool.

## Skills

| Skill | Description |
|-------|-------------|
| [git-ship](skills/git-ship/SKILL.md) | End-to-end git workflow: branch check, stage, commit, and optional PR creation |
| [pr-describe](skills/pr-describe/SKILL.md) | Write a reviewer-ready PR description: what changed, environments affected, deployment risk, and validation |
| [helm-check](skills/helm-check/SKILL.md) | Lint and render Helm charts locally — never installs or upgrades |
| [review](skills/review/SKILL.md) | Critically review a PR — self-configuring on first use: detects the repo's stack and interactively builds a tailored checklist |
| [tf-plan](skills/tf-plan/SKILL.md) | Run the terraform/tofu fmt → init → plan loop — never applies |
| [walkthrough](skills/walkthrough/SKILL.md) | Generate a linear code walkthrough using the `showboat` tool |

## Structure

```
skills/
  <skill-name>/
    SKILL.md        # skill definition
scripts/
  install-ccnotify.sh   # desktop notifications hook installer (macOS)
```

## Using Skills in Your Own Repo

Copy the `skills/` directories you want into your project, then generate a `CLAUDE.md` tailored to your repo — **do not copy this repo's `CLAUDE.md`**, as it describes the skills collection itself and won't reflect your project's conventions.

Your generated `CLAUDE.md` should include a section that tells Claude which skills are installed and when to invoke them. For example:

```markdown
## Skills

The following Claude Code skills are installed in `skills/`. Use them when the situation calls for it:

- `git-ship` — use for staging, committing, and opening PRs
- `review` — use when asked to review a PR or diff (run initialization on first use)
- `helm-check` — use before any Helm chart changes are merged
- `tf-plan` — use instead of running terraform manually
```

This ensures Claude actually reaches for the skills rather than defaulting to ad-hoc behavior.

## Adding a Skill

Create a new directory under `skills/` and add a `SKILL.md`. The directory name is the skill name users reference when invoking it. See [CLAUDE.md](CLAUDE.md) for conventions.

## See Also

- **[CCNotify](https://github.com/dazuiba/CCNotify)** — macOS desktop notifications when Claude needs input or finishes a task. Install via `bash scripts/install-ccnotify.sh` (requires Homebrew and `jq`).
- **[tcotav/ccode_infra_starter](https://github.com/tcotav/ccode_infra_starter/)** — Template for safely using Claude Code with Terraform and Helm in GCP environments. Expands on the `helm-check` and `tf-plan` skills with safety hooks, audit logging, and a Docker devcontainer.
- **[obra/superpowers](https://github.com/obra/superpowers)** — A complete software development workflow built on composable skills. Available as a Claude Code plugin.
- **[Linear Walkthroughs](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/)** (Simon Willison) — the pattern behind the `walkthrough` skill.
