#!/usr/bin/env bash
# vim: ft=sh

set -Eeuo pipefail

login() {
  local profile="$1"
  local region="$2"

  echo "logging into $1"

  aws sso login --profile "$profile" --region "$region" && aws eks update-kubeconfig --name "$profile" --profile "$profile" --region "$region"
}

AWS_PROFILE="${1:-"fg-staging"}"
AWS_REGION="${2:-"us-east-1"}"

case $AWS_PROFILE in
  *st*g*)
    AWS_PROFILE="fg-staging"
    AWS_REGION="us-east-1"
    ;;
  *ca*)
    AWS_PROFILE="fg-production-ca-central-1"
    AWS_REGION="ca-central-1"
    ;;
  *eu*)
    AWS_PROFILE="fg-production-eu-west-1"
    AWS_REGION="eu-west-1"
    ;;
  *prod | *prod*us* | *us*)
    AWS_PROFILE="fg-production"
    AWS_REGION="us-east-1"
    ;;
  all)
    PROFILE_REGIONS=("fg-staging:us-east-1" "fg-production:us-east-1" "fg-production-ca-central-1:ca-central-1" "fg-production-eu-west-1:eu-west-1")
    for profile_region in "${PROFILE_REGIONS[@]}"; do
      profile="${profile_region%%:*}"
      region="${profile_region##*:}"
      login "$profile" "$region" &
    done
    wait

    exit
    ;;
  *)
    echo "No matching profile found for $AWS_PROFILE"
    exit 1
    ;;
esac

login "$AWS_PROFILE" "$AWS_REGION"
echo "done!"
