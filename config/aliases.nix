{pkgs, ...}: {
  ".." = "cd ../";
  aws_us_prod = "export AWS_PROFILE=fg-production && export AWS_REGION=us-west-2";
  aws_ca_prod = "export AWS_PROFILE=fg-production-ca-central-1 && export AWS_REGION=ca-central-1";
  aws_eu_prod = "export AWS_PROFILE=fg-production-eu-west-1 && export AWS_REGION=eu-west-1";
  aws_stg = "export AWS_PROFILE=fg-staging && export AWS_REGION=us-west-2";
  k9s = "k9s --headless";
  sed = "${pkgs.gnused}/bin/sed";
  gsed = "${pkgs.gnused}/bin/sed";

  open-resume = "zathura ~/Projects/resume/Schurch-Jake-2024-Resume.pdf &";
  nix-setup = "~/.dots/./setup.sh";
  # docker = "colima";
  # ssh = "mosh";
  ap = "ansible-playbook";
  cat = "bat";
  dc = "docker compose";
  du = "dust";
  fg = " fg";
  find = "fd";
  k = "kubectl";
  ls = "lsd -lhSt --icon never --color auto --date relative";
  vi = "nvim";
  nvim = "nvim-open";
  n = "nvim-open";
  # vim = "nvim";

  r = "ranger";
  restart = "reboot";
  tf = "terraform";
  sf = "fish && source ~/.config/fish/config.fish";
  now = ''date -u +"%H:%M:%S"'';
  xclip = "xclip -sel clip <";

  grep = "${pkgs.gnugrep}/bin/grep";
  egrep = "${pkgs.gnugrep}/bin/egrep";
  fgrep = "${pkgs.gnugrep}/bin/fgrep";

  git = "${pkgs.git}/bin/git";

  nix-gc = "nix-collect-garbage";

  groot = "cd $(git top)";
  ka = "kubectl apply -f";
  kd = "kubectl delete -f";
  kud = "kustomize build . --enable-helm | kubectl delete -f";
  kua = "kustomize build . --enable-helm | kubectl apply -f";
}
