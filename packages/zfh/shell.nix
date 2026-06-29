{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "zfh";
  buildInputs = [
    cargo
    pandoc

    # typst-lua
    openssl
    pkg-config

    (luajit.withPackages (
      p: with p; [
        busted
        ldoc
        luarocks-build-rust-mlua
      ]
    ))
  ];
}
