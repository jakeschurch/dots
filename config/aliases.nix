_: {
  ".." = "cd ../";

  open-resume = "zathura ~/Projects/resume/Schurch-Jake-2024-Resume.pdf &";
  nix-setup = "~/.dots/./setup.sh";
  # docker = "colima";
  # ssh = "mosh";
  man = "batman";
  ap = "ansible-playbook";
  cat = "bat";
  dc = "docker compose";
  du = "dust";
  fg = " fg";
  find = "fd";
  g = "git";
  gco = "git checkout";
  gs = "git switch -c";
  k = "kubectl";
  ls = "lsd -lhSt --icon never --color auto --date relative";
  m = "pipenv run python manage.py";
  vi = "nvim_open";
  nvim = "nvim_open";
  n = "nvim_open";
  r = "ranger";
  restart = "reboot";
  tf = "terraform";
  vim = "nvim_open";
  sf = "fish && source ~/.config/fish/config.fish";
  now = ''date -u +"%H:%M:%S"'';
  xclip = "xclip -sel clip <";

  nix-gc = "nix-collect-garbage";
  tg = "terragrunt";
  tg_plan = "terragrunt run-all plan --terragrunt-source $(git rev-parse --show-toplevel)";
  tg_init = "terragrunt run-all init --terragrunt-source $(git rev-parse --show-toplevel)";
  tg_apply = "terragrunt run-all apply --terragrunt-source $(git rev-parse --show-toplevel)";

  groot = "cd $(git top)";
  ka = "kubectl apply -f";
  kd = "kubectl delete -f";
  kud = "kustomize build . --enable-helm | kubectl delete -f";
  kua = "kustomize build . --enable-helm | kubectl apply -f";
}
