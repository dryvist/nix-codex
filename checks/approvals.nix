{ pkgs, self }:
let
  evaluate = extra: pkgs.lib.evalModules { modules = [ self.homeModules.approvals ] ++ extra; };
  defaults = (evaluate [ ]).config;
  repeated = (evaluate [ self.homeModules.approvals ]).config;
  overridden =
    (evaluate [
      {
        programs.codex = {
          approvalPolicy = "never";
          approvalsReviewer = "auto_review";
        };
      }
    ]).config;
in
{
  approvals-options =
    assert defaults.programs.codex.approvalPolicy == "on-request";
    assert defaults.programs.codex.approvalsReviewer == "user";
    assert builtins.attrNames defaults == [ "programs" ];
    assert repeated == defaults;
    assert overridden.programs.codex.approvalPolicy == "never";
    assert overridden.programs.codex.approvalsReviewer == "auto_review";
    pkgs.writeText "codex-approvals-options" (builtins.toJSON { inherit defaults overridden; });
}
