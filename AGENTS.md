---
skill-groups: [core, nix]
---
# nix-codex - AI Agent Instructions

Declarative Codex CLI configuration in Nix. v0 exposes one pure renderer for
the autonomous (container-baked) Codex profile; nothing here touches a host
filesystem.

## Critical constraints

1. **Flakes-only**: never `nix-env` or imperative Nix commands.
2. **Hard parameterization**: every input is a function argument. No embedded
   permission data, no hard-coded home directory, no private-repo references —
   a stranger must be able to consume this flake unchanged.
3. **Purity**: `lib/` holds pure functions only. Rendering must never depend on
   the evaluating machine.
4. **No host deployment path**: the autonomous profile sets
   `sandbox_mode = "danger-full-access"`. Do not add a home-manager module that
   could write it to a laptop.
5. **git-flow**: feature branches off `develop`; `main` is the release branch.
   Conventional-commit subjects only.

## Validation

```bash
nix flake check   # renders the profile and asserts its posture
nix fmt           # nixfmt via nixfmt-tree
```

Every renderer gets an assertion in `checks/`. A change that alters rendered
bytes must update the check in the same commit.

## Layout

| Path                         | Holds                                        |
| ---------------------------- | -------------------------------------------- |
| `lib/render-autonomous.nix`  | The pure renderer (`config.toml` + rules)    |
| `checks/`                    | Derivation-based assertions on rendered text |
| `modules/`                   | Placeholder — see `modules/ROADMAP.md`       |

## Follow-up work

Migrating the interactive `programs.codex` home-manager module is deliberately
out of scope for v0. See `modules/ROADMAP.md` before starting it.
