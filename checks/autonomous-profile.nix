# Codex autonomous-profile render checks
#
# Asserts the container-image config produced by lib.renderAutonomous carries
# the expected posture (approval never / danger-full-access) and that every
# representable entry of the caller's residualDeny list reaches the execpolicy
# rules file as a `forbidden` prefix_rule. Guards against a refactor silently
# weakening the profile.
{ pkgs, self }:

let
  # Sample list, not a source of truth — consumers pass their own. The glob
  # entry is deliberate: it exercises the unrepresentable-command filter.
  residualDeny = [
    "gh repo delete"
    "gh repo archive"
    "gh repo edit"
    "gh secret"
    "gh variable"
    "gh release delete"
    "gh auth"
    "gh api -X DELETE"
    "gh api --method DELETE"
    "git push --force"
    "git push -f"
    "git push --delete"
    "npm publish"
    "cargo publish"
    "rm -rf /*"
  ];

  render = self.lib.renderAutonomous { inherit residualDeny; };
  expectedRules = builtins.length (render.supportedCommands residualDeny);
in
{
  autonomous-profile-render =
    pkgs.runCommand "codex-autonomous-profile-render"
      {
        codexConfig = render.configToml;
        codexRules = render.rules;
        passAsFile = [
          "codexConfig"
          "codexRules"
        ];
      }
      ''
        set -euo pipefail

        # Container-is-the-sandbox posture.
        grep -q 'approval_policy = "never"' "$codexConfigPath"
        grep -q 'sandbox_mode = "danger-full-access"' "$codexConfigPath"

        # Residual deny reached the execpolicy rules in Codex's native form.
        grep -q '"forbidden"' "$codexRulesPath"
        grep -Fq '["gh","repo","delete"]' "$codexRulesPath"

        # Every representable entry rendered — and the glob entry did not.
        [ "$(grep -c '"forbidden"' "$codexRulesPath")" -eq ${toString expectedRules} ]
        [ ${toString expectedRules} -eq $(( ${toString (builtins.length residualDeny)} - 1 )) ]
        grep -q 'Unsupported shell-only patterns were skipped: 1' "$codexRulesPath"

        touch "$out"
      '';
}
