{ pkgs, ... }:
{
  programs.lf = {
    enable = true;
    extraConfig = ''
      cmd paste &{{
          set -- $(cat ~/.local/share/lf/files)
          mode="$1"
          shift
          case "$mode" in
              copy)
                  rsync -av --ignore-existing --progress -- "$@" . |
                  stdbuf -i0 -o0 -e0 tr '\r' '\n' |
                  while IFS= read -r line; do
                      lf -remote "send $id echo $line"
                  done
                  ;;
              move) mv -n -- "$@" .;;
          esac
          rm ~/.local/share/lf/files
          lf -remote "send clear"
      }}

      cmd toggle_preview %{{
          if [ "$lf_preview" = "true" ]; then
              lf -remote "send $id :set preview false; set ratios 1:1"
          else
              lf -remote "send $id :set preview true; set ratios 1:2:3"
          fi
      }}

      map zp toggle_preview
      cmd bulk-rename $\{\{
          old="$(mktemp)"
          new="$(mktemp)"
          if [ -n "$fs" ]; then
              fs="$(basename -a $fs)"
          else
              fs="$(ls)"
          fi
          printf '%s\n' "$fs" >"$old"
          printf '%s\n' "$fs" >"$new"
          $EDITOR "$new"
          [ "$(wc -l < "$new")" -ne "$(wc -l < "$old")" ] && exit
          paste "$old" "$new" | while IFS= read -r names; do
              src="$(printf '%s' "$names" | cut -f1)"
              dst="$(printf '%s' "$names" | cut -f2)"
              if [ "$src" = "$dst" ] || [ -e "$dst" ]; then
                  continue
              fi
              mv -- "$src" "$dst"
          done
          rm -- "$old" "$new"
          lf -remote "send $id unselect"
      \}\}
    '';
    settings = {
      number = true;
      preview = true;
      relativenumber = true;
      ratios = [
        1
        2
        3
      ];
      drawbox = false;
      reverse = true;
      sortby = "time";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/bin/sh

      case "$1" in
          *.tar*) tar tf "$1";;
          *.zip) unzip -l "$1";;
          *.rar) unrar l "$1";;
          *.7z) 7z l "$1";;
          *.pdf) pdftotext "$1" -;;
          *) bat --color=always --style=numbers "$1";;
      esac
    '';
  };
}
