# modules/ roadmap — reserved for the interactive Codex module

`approvals.nix` is an options-only extension: it declares approval policy and
reviewer with neutral defaults and performs no rendering or activation.

The interactive Codex home-manager module (`programs.codex`: settings, MCP
servers, allow/ask/deny permission lists rendered to
`~/.codex/rules/default.rules`) still lives elsewhere and is a **documented
follow-up**, not part of this release. Migrating it here means moving the
remaining option schema, the permission-data plumbing it consumes, and its activation
tests together — a bigger change than v0's pure renderer.

Two constraints for whoever picks it up:

1. The interactive module must keep the same rules-file formatter as
   `lib/render-autonomous.nix`, so both profiles express a deny list in one
   format. Factor the formatter out rather than copying it.
2. The autonomous profile must stay unreachable from any home-manager code
   path — `sandbox_mode = "danger-full-access"` is safe only inside a
   container.
