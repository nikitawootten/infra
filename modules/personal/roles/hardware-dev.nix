{ ... }:
{
  flake.darwinModules.role-hardware-dev =
    { ... }:
    {
      homebrew.taps = [
        {
          name = "qmk/qmk";
          trusted = true;
        }
      ];
      homebrew.brews = [
        "qmk/qmk/qmk"
        "python@3.13"
      ];
    };
}
