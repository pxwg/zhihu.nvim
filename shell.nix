{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "zhihu.nvim";
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
