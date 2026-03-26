# Document Script Skill

Use this skill when asked to document a script, utility, or one-off tool — especially vibe-coded or quickly written scripts that need to survive beyond their creation.

Invoke when the user says things like "document this script", "add documentation for X", or "set up docs for the scripts in this directory".

---

## Step 1: Read the target script

Read the full content of the target script. If the user did not specify a file, ask which script to document.

Note the script's directory (`TARGET_DIR`) and base name without extension (`SCRIPT_BASE`).

---

## Step 2: Detect context

Run the following checks in parallel:

1. **showboat available?** — run `showboat --help` (exit 0 = present)
2. **CLAUDE.md exists?** — check for `TARGET_DIR/CLAUDE.md`
3. **Index section present?** — if CLAUDE.md exists, look for the `## Script documentation index` section
4. **Companion files exist?** — check for `SCRIPT_BASE.intent.md` and `SCRIPT_BASE.walkthrough.md`
5. **Other scripts present?** — list all scripts in `TARGET_DIR` (`.py`, `.sh`, `.rb`, `.ts`, `.js`, `.go` — anything executable or script-like), note which lack companion files

Use the detection results to determine the invocation context:

- **Clean slate**: no CLAUDE.md, no companions
- **Legacy directory**: CLAUDE.md exists but has no index section, or other scripts lack companions
- **Established convention**: CLAUDE.md with index section, other scripts are documented

---

## Step 3: Generate `<SCRIPT_BASE>.intent.md`

**If the intent file already exists**, stop and ask the user before overwriting. Say: "An intent file already exists at `<path>`. Overwrite, skip, or show diff?"

Otherwise, create `TARGET_DIR/<SCRIPT_BASE>.intent.md` by reasoning from the script's code. Infer purpose, decisions, limitations, and invariants. Use this template:

```markdown
# Intent: <script name>

## Purpose
What problem this solves and why it exists.

## Design decisions
- Why X was implemented this way (not just what it does)
- Why Y dependency was chosen over alternatives

## Known limitations
- Edge cases not handled
- Assumptions baked in

## Do not change
- Things that look wrong but must stay as-is (fragile env assumptions, upstream quirks, etc.)

## How to verify
- How to test that it still works correctly
```

Fill in each section from what you can infer from the code. For anything genuinely ambiguous, leave a `<!-- TODO: confirm with author -->` comment rather than guessing.

---

## Step 4: Generate `<SCRIPT_BASE>.walkthrough.md`

Add `<!-- generated: <today's date> -->` at the top of the file.

**If showboat is available**, use it to generate the walkthrough:

- Run `showboat --help` to confirm syntax
- Use `showboat note` for narrative commentary
- Use `showboat exec` with `sed`, `grep`, or `cat` to embed live code snippets
- Add a Mermaid diagram if the script has non-trivial control flow or multi-step data transformation
- Write to `TARGET_DIR/<SCRIPT_BASE>.walkthrough.md`

**If showboat is absent**, offer: "showboat is not installed. Install it with `uv tool install showboat` for richer output, or I can generate a plain markdown walkthrough now. Which do you prefer?"

- If user chooses install: run `uv tool install showboat`, then proceed with showboat
- If user chooses plain markdown: write a plain walkthrough to `TARGET_DIR/<SCRIPT_BASE>.walkthrough.md` with embedded fenced code blocks, narrative prose, and a Mermaid diagram if flow is complex

---

## Step 5: Create or update `CLAUDE.md` index

### If no `CLAUDE.md` exists
Create `TARGET_DIR/CLAUDE.md` with:

```markdown
## Script documentation index

When a new script is created in this directory, invoke the `document-script` skill on it before considering the task complete.

| Script | Intent | Walkthrough |
|--------|--------|-------------|
| <script file> | [<SCRIPT_BASE>.intent.md](<SCRIPT_BASE>.intent.md) | [<SCRIPT_BASE>.walkthrough.md](<SCRIPT_BASE>.walkthrough.md) |
```

### If `CLAUDE.md` exists and already has the index section
Add a new row for the script. Also check whether the instruction line ("When a new script is created in this directory...") is present in the index section — if missing, add it directly above the table. Do not modify any other content.

### If `CLAUDE.md` exists but has no index section
Append the following to the end of the file, preserving all existing content:

```markdown

---

## Script documentation index

<!-- Added by document-script skill -->

When a new script is created in this directory, invoke the `document-script` skill on it before considering the task complete.

| Script | Intent | Walkthrough |
|--------|--------|-------------|
| <script file> | [<SCRIPT_BASE>.intent.md](<SCRIPT_BASE>.intent.md) | [<SCRIPT_BASE>.walkthrough.md](<SCRIPT_BASE>.walkthrough.md) |
```

---

## Step 6: Offer batch documentation for legacy directories

If the detection in Step 2 found other scripts in the directory that lack companion files, say:

> "This directory has N other undocumented scripts: [list them]. Document them all now?"

If the user says yes, repeat Steps 3–5 for each undocumented script. Skip any that already have intent files (do not overwrite without confirmation).

---

## Safety

- **Never overwrite an existing `<name>.intent.md`** without explicit user confirmation. Intent files are manually maintained; regenerating them silently destroys design rationale.
- **Never overwrite unrelated content in an existing `CLAUDE.md`**. Always append the index section — never replace the file.
- **Walkthrough files may be regenerated freely** — they have a `<!-- generated: -->` stamp and are expected to go stale.
- Do not delete or rename any existing files.
