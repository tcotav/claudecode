# Claude Code Skills

A collection of custom skills for [Claude Code](https://claude.ai/code). Each skill is a markdown file that defines behavior Claude follows when invoked via the `Skill` tool.

## Skills

| Skill | Description |
|-------|-------------|
| [helm-check](skills/helm-check/SKILL.md) | Lint and render Helm charts locally — never installs or upgrades |
| [review](skills/review/SKILL.md) | Critically review a PR for permissions, test coverage, infrastructure impact, and type hints |
| [tf-plan](skills/tf-plan/SKILL.md) | Run the terraform/tofu fmt → init → plan loop — never applies |
| [walkthrough](skills/walkthrough/SKILL.md) | Generate a linear code walkthrough using the `showboat` tool |

## Structure

```
skills/
  <skill-name>/
    SKILL.md    # skill definition
```

## Adding a Skill

Create a new directory under `skills/` and add a `SKILL.md`. The directory name is the skill name users reference when invoking it. See [CLAUDE.md](CLAUDE.md) for conventions.

## References & Inspiration

- **[Linear Walkthroughs](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/)** (Simon Willison) — the pattern behind the `walkthrough` skill: prompt an agent to analyze a codebase and produce a structured explanation document using the `showboat` tool.

## External Skills & Plugins

- **[obra/superpowers](https://github.com/obra/superpowers)** — A complete software development workflow built on composable skills. Covers design/planning, TDD, git worktrees, code review, debugging, and more. Available as a Claude Code plugin.
