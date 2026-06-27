{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "auth";
  env = {
    SQLITE_INCDIR = "${sqlite.dev}/include";
    SQLITE_LIBDIR = "${sqlite.out}/lib";
  };
  buildInputs = [
    pkg-config
    sqlite
    cargo

    (luajit.withPackages (
      p: with p; [
        busted
        ldoc
        luarocks-build-rust-mlua
      ]
    ))
  ];
}
