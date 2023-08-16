inputs: 
{
  mkPackageSet = import ./mkPackageSet.nix;
  mkHomes = import ./mkHomes.nix inputs;
  mkHosts = import ./mkHosts.nix inputs;
}
