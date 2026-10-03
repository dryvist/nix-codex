{ lib, ... }:
{
  options.programs.codex = {
    approvalPolicy = lib.mkOption {
      type = lib.types.enum [
        "untrusted"
        "on-failure"
        "on-request"
        "never"
      ];
      default = "on-request";
      description = "When Codex requests approval, rendered as approval_policy by the consumer.";
    };

    approvalsReviewer = lib.mkOption {
      type = lib.types.enum [
        "user"
        "auto_review"
      ];
      default = "user";
      description = ''
        Who reviews Codex approval requests, rendered as approvals_reviewer by
        the consumer. Use auto_review with on-request for Approve for me.
      '';
    };
  };
}
