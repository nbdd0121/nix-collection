{
  lib,
  fetchFromGitHub,
  buildPythonApplication,
  django,
  psycopg2,
  djangorestframework,
  django-filter,
  mysqlclient,
}:
buildPythonApplication rec {
  pname = "patchwork";
  version = "3.2.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "getpatchwork";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-NXZvL7sxwXKqaBlxJoEXx1S/iyt3fQV3v5pL6BtXMxI=";
  };

  propagatedBuildInputs = [
    django
    psycopg2
    djangorestframework
    django-filter
    mysqlclient
  ];

  installPhase = ''
    mkdir -p $out/share/patchwork
    cp -r . $out/share/patchwork
    chmod +x $out/share/patchwork/manage.py
    makeWrapper $out/share/patchwork/manage.py $out/bin/patchwork --prefix PYTHONPATH : "$PYTHONPATH"

    # Read config data from /etc/patchwork/settings.py
    ln -s /etc/patchwork/settings.py $out/share/patchwork/patchwork/settings/production.py
  '';

  meta = with lib; {
    description = "A web-based patch tracking system designed to facilitate the contribution and management of contributions to an open-source project.";
    homepage = "https://github.com/getpatchwork/patchwork";
    license = licenses.gpl2Only;
    mainProgram = "patchwork";
  };
}
