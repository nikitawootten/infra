{ ... }:
{
  flake.darwinModules.role-hardware-dev =
    { ... }:
    {
      homebrew.brews = [
        "qmk/qmk/qmk"
        "python@3.13"
      ];
    };
}
