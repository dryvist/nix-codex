# nix-codex

> Declarative Codex CLI configuration in Nix — pure renderers for
> `config.toml` and execpolicy rules, hard-parameterized for any consumer.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Nix Flake](https://img.shields.io/badge/Nix-flake-blue.svg)](https://nixos.org)

A small Nix flake that renders [Codex CLI](https://github.com/openai/codex)
configuration as data. v0 covers the **autonomous profile**: the
`~/.codex/config.toml` and `~/.codex/rules/default.rules` pair baked into
agent container images, where safety comes from the container boundary and a
residual deny list rather than interactive approval prompts.

Every input is a function argument — there is no embedded permission data, no
hard-coded home directory, and no reference to any private repository. Pass
your own `residualDeny` list and you get your own files.

## Installation

```nix
{
  inputs.nix-codex.url = "github:dryvist/nix-codex";
}
```

## Usage

```nix
{ inputs, ... }:
let
  codex = inputs.nix-codex.lib.renderAutonomous {
    homeDir = "/home/agent";
    residualDeny = [
      "gh repo delete"
      "gh secret"
      "git push --force"
      "npm publish"
    ];
  };
in
# codex.files :: { ".codex/config.toml" = "..."; ".codex/rules/default.rules" = "..."; }
# Bake each home-relative path under homeDir in your image builder.
codex.files
```

### API

| Export                    | Purity | Returns                                            |
| ------------------------- | ------ | -------------------------------------------------- |
| `lib.renderAutonomous`    | pure   | `{ files; configToml; rules; residualDeny; ... }`  |
| `.files`                  | data   | Home-relative path -> contents, ready to bake      |
| `.configToml`             | data   | `approval_policy = "never"`, `danger-full-access`  |
| `.rules`                  | data   | execpolicy `prefix_rule(..., "forbidden")` lines   |
| `.commandIsRepresentable` | pure   | Whether a command can become a literal prefix rule |
| `.supportedCommands`      | pure   | The subset of a list that renders to rules         |

`renderAutonomous` takes `{ residualDeny, homeDir ? "/home/agent" }`.
`residualDeny` is required — there is no default deny list to inherit.

### Unrepresentable commands are dropped

Codex execpolicy `prefix_rule` matches literal argv tokens, so a command
carrying a glob or shell metacharacter (`*`, `|`, `$`, `;`, …) cannot be
expressed. Such entries are **silently dropped** rather than mangled into a
rule that would match the wrong argv, and the count is recorded in the rules
file header (`Unsupported shell-only patterns were skipped: N`). Use
`supportedCommands` if you need to know which entries survived.

### Approval options

`homeModules.approvals` declares `programs.codex.approvalPolicy` (default
`"on-request"`) and `programs.codex.approvalsReviewer` (default `"user"`). It
only declares options: consumers own TOML rendering and activation.

```nix
{
  imports = [ inputs.nix-codex.homeModules.approvals ];
  programs.codex = {
    approvalPolicy = "on-request";
    approvalsReviewer = "auto_review";
  };
}
```

This selects Codex's **Approve for me** setting when a consumer renders the
options as `approval_policy` and `approvals_reviewer`. Ordinary explicit Nix
definitions override the option defaults. The autonomous renderer remains
separate and writes no host files.

## Roadmap

- **Interactive Codex home-manager module.** Migrating the interactive
  `programs.codex` module (settings, MCP servers, permission lists) is a
  documented follow-up, not part of v0. See [`modules/ROADMAP.md`](modules/ROADMAP.md).

## Validation

```bash
nix flake check   # renders the profile and asserts its posture
nix fmt           # nixfmt via nixfmt-tree
```

## Compatibility

| Component | Supported                                                          |
| --------- | ------------------------------------------------------------------ |
| Codex CLI | latest stable                                                      |
| nixpkgs   | `nixos-unstable` (override via `inputs.nix-codex.inputs.nixpkgs`)  |
| Platforms | `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`, `x86_64-linux` |

## Contributing

Renderers are pure functions under `lib/`; every one gets an assertion in
`checks/`. Conventional-commit subjects only; feature branches off `develop`.

## License

MIT © Jacob P. Evans — see [LICENSE](LICENSE).
