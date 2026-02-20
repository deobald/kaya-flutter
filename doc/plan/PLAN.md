# Plan Documents

LLM agents must create a Markdown plan document **in this directory** (`doc/plan/`) before adding any feature or performing any refactoring, named with this pattern:

* `2025-12-25-add-job-for-plaintext-indexing.md`
* `2026-01-31-r-extract-behavior-from-controllers-to-models.md` ('r' for 'refactoring')
* `2027-01-13-fix-save-metadata-button-is-never-enabled.md`

Before creating the plan, read these documents:

* [@README.md](../../README.md)
* [@AGENTS.md](../../AGENTS.md)
* [doc/design/DESIGN.md](../design/DESIGN.md)
* [doc/arch/*.md](../arch/)

Then create the plan **in `doc/plan/`** and ask any clarifying questions you have. After I answer your questions to eliminate ambiguity, adjust the plan accordingly. Ask more clarifying questions, if required, and repeat the process until all your questions are answered.

**Important:** The plan file must be written to `doc/plan/` at the start of work, not to any tool-internal or temporary location. If your tooling uses a separate plan file path, copy or write the plan to `doc/plan/` as the first step. The plan document in this directory is the canonical record of what was done and why.

## Implementation

Before implementing a new feature or fixing a bug, **always write a failing test first.** Only if the modification required is purely limited to presentation logic should the testing step be skipped. Do not test the view layer.
