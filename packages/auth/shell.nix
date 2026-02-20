{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "auth";
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
