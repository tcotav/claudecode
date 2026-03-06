# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of custom Claude Code skills. Each skill is a markdown file (`SKILL.md`) that defines behavior for Claude when invoked via the `Skill` tool in Claude Code.

> **Note:** This `CLAUDE.md` is specific to maintaining this skills collection. Do not copy it into other projects. Repos that install skills from here should generate their own `CLAUDE.md` from their project's context, but must include a section listing the installed skills and when to invoke them — otherwise Claude will not reliably use them.

## Structure

```
skills/
  <skill-name>/
    SKILL.md    # skill definition
```

## Skill Format

Each `SKILL.md` should include:
- A clear title describing what the skill does
- A trigger/description line for when to invoke it
- Step-by-step instructions Claude should follow
- A **Safety** section for any destructive operations the skill must never perform

The `walkthrough` skill has a YAML front matter block (`name:`, `description:`) while others use plain markdown headers — both formats are in use.

## Adding a New Skill

Create a new directory under `skills/` and add a `SKILL.md` file. The skill name (directory name) is what users reference when invoking it.

## Skill Conventions

- Skills for infrastructure tools (helm-check, tf-plan) explicitly list forbidden commands to prevent destructive operations
- Skills that detect tools (tf-plan) check for alternatives in a defined priority order
- The walkthrough skill depends on the `showboat` tool (`uv tool install showboat`)
- Skills that ship as **generic placeholders** use a `<!-- configured: false -->` HTML comment sentinel. On first invocation the skill detects it, offers to initialize interactively, and uses the Edit tool to populate project-specific rules and flip the marker to `<!-- configured: true -->`. The `review` skill follows this pattern.
