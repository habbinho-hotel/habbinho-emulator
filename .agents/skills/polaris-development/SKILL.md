---
name: polaris-development
description: Develop and review Polaris changes using the Habbinho fork's workflow, compatibility contracts, fixtures, and CI.
---

# Polaris development

1. Read [AGENTS.md](../../../AGENTS.md), [CONTRIBUTING.md](../../../CONTRIBUTING.md),
   and the relevant guide in the [documentation index](../../../docs/README.md).
2. For branch status or overlap with recent commits, run the preflight from the
   repository root. It reads local Git refs and reports the current state.

   ```sh
   bash .agents/skills/polaris-development/scripts/preflight.sh "relevant keyword"
   ```

   Pass `--base <ref>` for a PR with a different target. The default uses the
   fetched default branch of `origin` (`origin/main` in Habbinho). Refresh the
   target ref when you need current remote state. Keep existing worktree changes
   intact. Search source, tests, and migrations for the behavior before implementing.

3. Preserve plugin ABI, packet field order and types, and migration history. Use
   [fixtures and contracts](references/fixtures-and-contracts.md) to choose what
   to extend for the affected boundary.
4. Run the focused test, then the relevant checks from
   [CI and local validation](references/ci-validation.md). Report what ran and
   any checks that remain unverified.
