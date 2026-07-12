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
        {
          name = "osx-cross/arm";
          trusted = true;
        }
        {
          name = "osx-cross/avr";
          trusted = true;
        }
      ];
      homebrew.brews = [
        "qmk/qmk/qmk"
        "python@3.13"
      ];
    };
}
