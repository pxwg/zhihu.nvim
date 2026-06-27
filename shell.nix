{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "zhihu.nvim";
  env = {
    STDCPP_LIBDIR = "${stdenv.cc.cc.lib}/lib";
    OPENSSL_INCDIR = "${openssl.dev}/include";
    OPENSSL_LIBDIR = "${openssl.out}/lib";
  };
  buildInputs = [
    openssl

    (luajit.withPackages (
      p: with p; [
        busted
        ldoc
      ]
    ))
  ];
}
