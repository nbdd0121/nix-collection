final: prev: {
  python3Packages = prev.python3Packages.override {
    overrides = py-final: py-prev: {
      # Fix https://github.com/newren/git-filter-repo/issues/659
      git-filter-repo = py-prev.git-filter-repo.overrideAttrs {
        src = prev.fetchFromGitHub {
          owner = "newren";
          repo = "git-filter-repo";
          rev = "d7b75aca907380f608892cc289e616f195427b99";
          hash = "sha256-7orjdEms3pzZbmaX8YeGzt4zYpIi0qfhj6yLDcr/aMg=";
        };
      };
    };
  };
}
