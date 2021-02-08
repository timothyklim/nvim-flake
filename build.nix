{ pkgs, src }:

with pkgs;
with pkgs.lib;
let
  doCheck = false;
  lua = luajit_2_1;
  neovimLuaEnv = lua.withPackages (ps:
    (with ps; [ lpeg luabitop mpack ]
      ++ optionals doCheck [
      nvim-client
      luv
      coxpcall
      busted
      luafilesystem
      penlight
      inspect
    ]
    ));

  pyEnv = python.withPackages (ps: [ ps.pynvim ps.msgpack ]);

  # FIXME: this is verry messy and strange.
  # see https://github.com/NixOS/nixpkgs/pull/80528
  luv = lua.pkgs.luv;
  luvpath = "${luv}/lib/lua/${lua.luaversion}/luv.so";
in
stdenv.mkDerivation {
  pname = "nvim";
  version = "0.5.0-dev";
  src = src;
  dontFixCmake = true;
  enableParallelBuilding = true;

  buildInputs = [
    gperf
    libtermkey
    libuv
    libvterm-neovim
    luv.libluv
    msgpack
    ncurses
    neovimLuaEnv
    unibilium
    tree-sitter
  ] ++ optionals doCheck [ glibcLocales procps ];

  inherit doCheck;

  # to be exhaustive, one could run
  # make oldtests too
  checkPhase = ''
    make functionaltest
  '';

  nativeBuildInputs = [
    cmake
    gettext
    pkgconfig
  ];

  # extra programs test via `make functionaltest`
  checkInputs = [
    fish
    nodejs
    pyEnv # for src/clint.py
  ];


  # nvim --version output retains compilation flags and references to build tools
  postPatch = ''
    substituteInPlace src/nvim/version.c --replace NVIM_VERSION_CFLAGS "";
  '';
  # check that the above patching actually works
  disallowedReferences = [ stdenv.cc ];

  cmakeFlags = [
    "-DGPERF_PRG=${gperf}/bin/gperf"
    "-DLUA_PRG=${neovimLuaEnv.interpreter}"
    "-DLIBLUV_LIBRARY=${luvpath}"
  ]
  ++ optional doCheck "-DBUSTED_PRG=${neovimLuaEnv}/bin/busted"
  ;

  # triggers on buffer overflow bug while running tests
  hardeningDisable = [ "fortify" ];

  postInstall = ''
    sed -i -e "s|'xsel|'${xsel}/bin/xsel|g" $out/share/nvim/runtime/autoload/provider/clipboard.vim
  '';

  # export PATH=$PWD/build/bin:${PATH}
  shellHook = ''
    export VIMRUNTIME=$PWD/runtime
  '';
}
