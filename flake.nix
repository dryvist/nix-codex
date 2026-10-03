{
  description = "Declarative Codex CLI in Nix — pure renderers for Codex config.toml and execpolicy rules, hard-parameterized for any consumer.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      lib.renderAutonomous = args: import ./lib/render-autonomous.nix ({ inherit lib; } // args);

      homeModules.approvals.imports = [ ./modules/approvals.nix ];

      checks = forAllSystems (
        pkgs:
        (import ./checks/autonomous-profile.nix { inherit pkgs self; })
        // (import ./checks/approvals.nix { inherit pkgs self; })
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell { packages = [ pkgs.nixfmt-tree ]; };
      });
    };
}
