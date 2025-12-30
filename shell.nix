{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "zhihu_neovim";
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
