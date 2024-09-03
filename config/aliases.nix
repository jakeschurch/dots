_: {
  ".." = "cd ../";
  aws_prod_us = "export AWS_PROFILE=fg-production && export AWS_REGION=us-west-2";
  aws_prod_ca = "export AWS_PROFILE=fg-production-ca-central-1 && export AWS_REGION=ca-central-1";
  aws_prod_eu = "export AWS_PROFILE=fg-production-eu-west-1 && export AWS_REGION=eu-west-1";
  aws_staging = "export AWS_PROFILE=fg-staging && export AWS_REGION=us-west-2";
  k9s = "k9s --headless";

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

  groot = "cd $(git top)";
  ka = "kubectl apply -f";
  kd = "kubectl delete -f";
  kud = "kustomize build . --enable-helm | kubectl delete -f";
  kua = "kustomize build . --enable-helm | kubectl apply -f";
}
