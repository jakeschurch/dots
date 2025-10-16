#!/usr/bin/env bash

set -Eeuo pipefail

sso_login() {
  local profile="$1"
  local region="$2"

  if aws sts get-caller-identity --profile "$profile" &>/dev/null; then
    echo "already logged into $1"
  else
    echo "logging into $1"
    aws sso login --profile "$profile" --region "$region"
  fi
}

profile_login() {
  local profile="$1"
  local region="$2"

  aws eks update-kubeconfig --name "$profile" --profile "$profile" --region "$region" >/dev/null
  echo "k8s context updated for $profile"
}

aws_config=$(parse_aws_config)

parse_json() {
  local json="$1"

  for profile in $(echo "$json" | jq -r '.sso_sessions | keys[]'); do
    region=$(echo "$json" | jq -r ".sso_sessions[\"$profile\"]")
    echo "SSO session for $profile in region $region"
    sso_login "$profile" "$region"
  done

  for profile in $(echo "$json" | jq -r '.profiles | keys[]'); do
    region=$(echo "$json" | jq -r ".profiles[\"$profile\"]")
    echo "Profile login for $profile in region $region"
    profile_login "$profile" "$region"
  done
}

parse_json "$aws_config"
