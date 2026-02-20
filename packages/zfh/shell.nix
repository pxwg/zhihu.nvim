{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "zfh";
  buildInputs = [
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
