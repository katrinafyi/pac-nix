final: prev:
{

  aslp-cpp = prev.callPackage ./aslp-cpp.nix { };

  inherit (final.ocamlPackages_pac) aslp asli aslp_web;

  overlay_ocamlPackages = ofinal: oprev: {

    asli = ofinal.callPackage ./asli.nix { inherit (final) z3; ocaml_z3 = ofinal.z3; zarith_stubs_js = ofinal.zarith_stubs_js_0_17; };
    aslp = ofinal.asli;
    # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }

    zarith_stubs_js_0_17 = ofinal.callPackage ./zarith_stubs_js.nix { };
    aslp_web = ofinal.callPackage ./aslp_web.nix { };

    mlbdd = ofinal.callPackage ./mlbdd.nix { };

    buildDunePackage = final.makeOverridable ({ pname, version, ... }@args:
      let
        args' = builtins.removeAttrs args [ "minimalOCamlVersion" ];
        ocaml = ofinal.ocaml;
        minOCaml = args.minimalOCamlVersion or args.minimumOCamlVersion or "0";
        guard = x:
          if ! final.lib.versionAtLeast ocaml.version minOCaml
          then throw "${pname}-${version} is not available for OCaml ${ocaml.version} (requires at least ${minOCaml})"
          else x;
        result = oprev.buildDunePackage args';
      in
      result.overrideAttrs { name = guard result.name; }
    );

    overrideDunePackage = f: drv:
      drv.override (args: {
        buildDunePackage = drv_: (args.buildDunePackage drv_).override f;
      });

    ocaml_pcre = ofinal.overrideDunePackage
      rec {
        version = "7.4.6";
        minimalOCamlVersion = "4.08";
        src = prev.fetchurl {
          url = "https://github.com/mmottl/pcre-ocaml/releases/download/${version}/pcre-${version}.tbz";
          sha256 = "17ajl0ra5xkxn5pf0m0zalylp44wsfy6mvcq213djh2pwznh4gya";
        };
      }
      oprev.ocaml_pcre;

  };
}

