{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Nikita Wootten";
    userEmail = "nikita.wootten@gmail.com";
    extraConfig = {
      fetch.prune = true;
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
