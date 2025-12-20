final: prev:
{

  aslp-cpp = prev.callPackage ./aslp-cpp.nix { };

  inherit (final.ocamlPackages_pac) aslp asli;
  inherit (final.ocamlPackages_pac) aslp_web;
  inherit (final.ocamlPackages_pac) aslp-server;
  inherit (final.ocamlPackages_pac) aslp_client_server_ocaml;
  inherit (final.ocamlPackages_pac) aslp_offline;
  inherit (final.ocamlPackages_pac) aslp_offline_js;

  overlay_ocamlPackages = ofinal: oprev: {
    asli = ofinal.callPackage ./asli.nix { inherit (final) z3; ocaml_z3 = ofinal.z3; };
    aslp = ofinal.asli;
    # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }
    aslp-server = ofinal.callPackage ./aslp-server.nix {};
    aslp_server_http = ofinal.aslp-server;


    aslp_offline = ofinal.callPackage ./aslp_offline.nix { };
    aslp_offline_js = ofinal.callPackage ./aslp_offline_js.nix { zarith_stubs_js = ofinal.zarith_stubs_js_0_17; };

    zarith_stubs_js_0_17 = ofinal.callPackage ./zarith_stubs_js.nix { };
    aslp_web = ofinal.callPackage ./aslp_web.nix { zarith_stubs_js = ofinal.zarith_stubs_js_0_17; };
    aslp_client_server_ocaml = ofinal.callPackage ./aslp_client_server_ocaml.nix { };

    mlbdd = ofinal.callPackage ./mlbdd.nix { };
    cohttp = oprev.cohttp.overrideAttrs (p: rec {
      version = "6.0.0";
      src = final.fetchurl {
        url = "https://github.com/mirage/ocaml-cohttp/releases/download/v${version}/cohttp-${version}.tbz";
        hash = "sha256-VMw0rxKLNC9K5gimaWUNZmYf/dUDJQ5N6ToaXvHvIqk=";
      };
      propagatedBuildInputs = p.propagatedBuildInputs ++ [ ofinal.cohttp-http ofinal.logs ];
      doCheck = false;
    });
    cohttp-eio = ofinal.callPackage ./cohttp-eio.nix {};
    cohttp-http = ofinal.callPackage ./cohttp-http.nix {};

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


    mirage-crypto-rng = oprev.mirage-crypto-rng.overrideAttrs { doCheck = false; };
  };
}

