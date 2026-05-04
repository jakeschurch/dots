{ lib, pkgs, ... }:
let
  languages = [
    "bash"
    "lua"
    "python"
    "yaml"
    "json"
    "sh"
  ];

  mkInjectionBlock = lang: ''
    (
      (comment) @_comment
      .
      (_) @injection.content
      (#match? @_comment "language=${lang}")
      (#set! injection.language "${lang}")
      (#set! injection.include-children)
    )
  '';

  mkStringInjection = lang: ''
    (
      (string_expression
        (string_fragment) @injection.content)
      (#match? @injection.content "(^|\\n)[ \\t]*#\\s*language=${lang}")
      (#set! injection.language "${lang}")
      (#set! injection.include-children)
    )
  '';

  mkInjectionFile =
    langs: lib.concatStringsSep "\n" ((map mkInjectionBlock langs) ++ (map mkStringInjection langs));

  sharedInjectionFile = pkgs.writeText "treesitter-injections.scm" (mkInjectionFile languages);

  hostLanguages = [
    "nix"
    "yaml"
    "lua"
    "bash"
    "sh"
    "python"
  ];

  mkQueryEntry = lang: {
    name = "nvim/queries/${lang}/injections.scm";
    value = {
      source = sharedInjectionFile;
    };
  };

in
lib.listToAttrs (map mkQueryEntry hostLanguages)
