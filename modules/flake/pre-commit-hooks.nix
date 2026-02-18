{ inputs, ... }:
{
  imports = [
    inputs.pre-commit-hooks.flakeModule
  ];
}
