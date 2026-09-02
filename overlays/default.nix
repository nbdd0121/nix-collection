lib: rec {
  git-filter-repo = import ./git-filter-repo.nix;
  default = lib.composeManyExtensions [
    git-filter-repo
  ];
}
