---
name: create-jira-tickets
description: Use when a TASKS.md or approved work breakdown exists and the user wants to create Jira issues from it, including epics, subtask parenting, field inheritance, and dependency links between tickets
---

# Create Jira Tickets

Create Jira issues from an approved task breakdown, with blocker relationships and consistent formatting.

## When to Use

- A `TASKS.md` (or equivalent work breakdown) has been reviewed and approved
- The user wants actual Jira issues created, not just a document

**Not for:** creating a task breakdown (use `project-sprint-planning`).

## Prerequisites

- Atlassian MCP must be connected (`/mcp` to verify)

## Process

### Step 1: Read the task breakdown

Read `TASKS.md`. Extract for each task:
- Title / summary
- Full description
- Story points and hour estimate
- Dependencies (blockedBy task IDs)

### Step 2: Ask clarifying questions

Ask branching questions sequentially (each answer may change the next question). Ask independent optional questions together in one message.

**Sequential (ask in order, each may affect the next):**

1. **Jira project key** — e.g., `PLAT`
2. **Issue type** — default: `Task`; only ask if the user wants a different type (e.g., Story)
3. **Epic** — "Do you want to link these tickets to an existing epic, create a new epic to group them under, or skip?"
   - *Existing epic*: ask for the epic key (e.g., `PLAT-10`)
   - *New epic*: ask for the epic name/summary; you will create it before any tasks in Step 4
   - *None*: skip epic linking entirely
4. **Subtask parent** — "Should these be created as subtasks of an existing Jira issue?" If yes, ask for the parent issue key (e.g., `PLAT-42`). **This overrides the issue type** — all issues will be created as `Sub-task` instead. If the user provides both a subtask parent and an existing epic, note that in next-gen Jira `parent` cannot hold both relationships simultaneously and ask which takes precedence.

**Independent (ask together in one message):**

- **Assignee** — optional; leave blank if not specified
- **Sprint** — optional; leave blank if not specified

Fields like Labels, Components, Fix Versions, and Priority are inherited from the parent (if one exists) or left blank for the user to set manually after creation.

### Step 3: Present plan and wait for explicit confirmation

**If an existing parent key was provided** (existing epic key or subtask parent key), fetch it first using `mcp__atlassian__getJiraIssue` and extract these inheritable fields:

- Labels
- Components
- Fix Versions
- Priority

Do **not** inherit: Assignee, Reporter, Sprint, Story Points, Summary, Description, or issue type.

If both a subtask parent and an existing epic are provided, use the subtask parent's fields as primary. If a field is absent on the subtask parent but present on the epic, inherit it from the epic and note the source in the plan.

If a new epic is being created (not yet existing), there is nothing to fetch — no inheritance applies.

If no parent exists, these fields will be left blank.

Now present a full summary of every action that will be taken and **stop**. Do not proceed until the user explicitly confirms.

The summary must include:

1. **Epic action** (if applicable): "Create new epic: `<name>`" or "Link to existing epic: `<key>`" or "No epic"
2. **Subtask parent** (if applicable): "Create all issues as subtasks of `<key>`"
3. **Inherited fields** (if a parent was fetched): list each non-empty field and its value, e.g.:
   - Labels: `platform`, `q2`
   - Components: `API Gateway`
   - Fix Versions: `2026.2`
   - Priority: `High`

   State: "These will be applied to all child issues. Override any before confirming if needed."
4. **Issue list** — one row per task, in the order they will be created. The Blocks column serves as the blocker link plan:

| # | Summary | Type | Points | Epic | Parent | Blocks |
|---|---------|------|--------|------|--------|--------|
| 1 | Generate Fastly API key | Task | 1 | PLAT-109 | — | #2 |
| 2 | Store API key in Secret Manager | Task | 3 | PLAT-109 | — | — |

End the summary with: **"Proceed with creating these X issues in Jira? (yes / no / edit)"**

If the user says no or requests edits, incorporate their changes and re-present the summary. Do not write anything to Jira until the user says yes.

### Step 4: Create issues in dependency order

**If creating a new epic**, create it first — before any tasks. Use `mcp__atlassian__createJiraIssue` with `issuetype: "Epic"` and the epic name the user provided. Record the returned key (e.g., `PLAT-109`) as `EPIC_KEY`. This epic is implicitly a prerequisite of all tasks; do not add it as a blocker link in Step 5.

Then create tasks with no inter-task dependencies first, followed by tasks that depend on them. This ensures blocker links can be set immediately after creation.

For each task, use `mcp__atlassian__createJiraIssue` with:
- `summary`: task title
- `description`: full task description including story points and hour estimate (use Jira wiki markup or plain text)
- `issuetype`: `Sub-task` if a subtask parent was provided; otherwise the type from Step 2 (e.g., `Task` — never `Epic`)
- `project`: project key from Step 2
- `story_points`: numeric point value if the project has a story points field
- **Inherited fields**: apply labels, components, fix versions, and priority fetched in Step 3 (as approved). Do not apply assignee even if present on the parent.
- **Parent (subtask)**: if a subtask parent key was provided, set the `parent` field to that key. This applies in both classic and next-gen Jira for subtasks.
- **Epic link**: if an epic key was provided or just created, include it. In classic Jira this is `customfield_10014`; in next-gen/team-managed projects it is the `parent` field.

Before creating the first task, if the story points field name or epic link field name is uncertain, call `mcp__atlassian__getJiraIssueTypeMetaWithFields` **once** and use the result for both. Do not call it per-issue.

Keep a mapping of `TASK-N → Jira issue key` (e.g., `TASK-4 → PLAT-112`) as you go.

### Step 5: Set blocker links

For each dependency declared in TASKS.md, use `mcp__atlassian__createIssueLink` with link type `"blocks"`:
- The blocking issue (dependency) blocks the dependent issue

Use `mcp__atlassian__getIssueLinkTypes` first if unsure of the exact link type name in this Jira instance.

### Step 6: Report back

Present a table of created issues:

| Task | Jira Key | Summary | Points | Epic | Parent | Blocks |
|---|---|---|---|---|---|---|
| *(epic)* | PLAT-109 | Q2 API Integration | — | — | — | — |
| TASK-1 | PLAT-110 | Generate Fastly API key | 1 | PLAT-109 | — | PLAT-111 |
| TASK-2 | PLAT-111 | Store API key in Secret Manager | 3 | PLAT-109 | — | — |

Include a direct link to the Jira project board if available.

## Common Mistakes

- **Writing before confirmation** — never call any Jira write API (`createJiraIssue`, `createIssueLink`) before the user explicitly approves the plan in Step 3
- **Creating in wrong order** — create the epic first (if new), then dependencies before dependents so blocker links work
- **Losing the task→key mapping** — write it down as you go; you'll need it for blocker links and the final table
- **Skipping the link step** — blocker relationships are half the value; don't skip them
- **Wrong link direction** — "TASK-1 blocks TASK-2" means TASK-1 must complete before TASK-2 starts; double-check direction before submitting
- **Conflating epic links with blocker links** — epic membership and subtask parenting are set via fields on issue creation; neither should be added via `createIssueLink`
- **Wrong epic field** — classic Jira uses `customfield_10014` for epic link; next-gen uses `parent`; check the field schema first if unsure rather than guessing
- **Wrong issue type for subtasks** — subtasks must use `issuetype: "Sub-task"`, not `Task`; forgetting this will either error or create a top-level issue with no parent
- **Blocker links between subtasks** — some Jira configurations do not support issue links between subtasks; if `createIssueLink` fails for subtask-to-subtask links, note the limitation in the report rather than retrying
- **Inheriting assignee** — do not copy assignee from the parent
- **Skipping the fetch when a parent exists** — inherited fields must be shown in the Step 3 plan before any writes; don't skip the fetch and silently omit fields
