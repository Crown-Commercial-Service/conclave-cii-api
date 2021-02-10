#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h                    - help"
  echo "  -u <CF_USER>          - CloudFoundry user             (required)"
  echo "  -p <CF_PASS>          - CloudFoundry password         (required)"
  echo "  -o <CF_ORG>           - CloudFoundry org              (required)" 
  echo "  -s <CF_SPACE>         - CloudFoundry space to target  (required)" 
  echo "  -a <CF_API_ENDPOINT>  - CloudFoundry API endpoint     (default: https://api.london.cloud.service.gov.uk)"
  echo "  -f                    - Force a deploy of a non standard branch to staging or develop"
  exit 1
}

# if there are no arguments passed exit with usage
if [ $# -lt 0 ];
then
 usage
fi

SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

CF_API_ENDPOINT="https://api.london.cloud.service.gov.uk"

while getopts "a:u:p:o:s:h:f" opt; do
  case $opt in
    u)
      CF_USER=$OPTARG
      ;;
    p)
      CF_PASS=$OPTARG
      ;;
    o)
      CF_ORG=$OPTARG
      ;;
    s)
      CF_SPACE=$OPTARG
      ;;
    a)
      CF_API_ENDPOINT=$OPTARG
      ;;
    f)
      FORCE=yes
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

if [[ -z "$CF_USER" || -z "$CF_PASS" || -z "$CF_ORG" || -z "$CF_SPACE" ]]; then
  usage
fi

if [ ! -z ${TRAVIS_BRANCH+x} ]
then
 git checkout $TRAVIS_BRANCH
fi

BRANCH=$(git symbolic-ref --short HEAD)
echo "INFO: deploying $BRANCH to $CF_SPACE"

if [[ ! "$FORCE" == "yes" ]]
then

  if [[ "$CF_SPACE" == "development" ]]
  then
    if [[ ! "$BRANCH" == "develop" ]]
    then
      echo "We only deploy the 'develop' branch to the $CF_SPACE cf space"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi

  if [[ "$CF_SPACE" == "testing" ]]
  then
    if [[ ! "$BRANCH" == "staging" ]]
    then
      echo "We only deploy the 'staging' branch to the $CF_SPACE cf space"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi

  if [[ "$CF_SPACE" == "integration" ]]
  then
    if [[ ! "$BRANCH" == "integration" ]]
    then
      echo "We only deploy the 'integration' branch to the $CF_SPACE cf space"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi

  if [[ "$CF_SPACE" == "preproduction" || "$CF_SPACE" == "production" ]]
  then
    if [[ ! "$BRANCH" == "main" ]]
    then
      echo "We only deploy the 'main' branch to the $CF_SPACE cf space"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi

  if [[ "$CF_SPACE" == "sandbox" ]]
  then
    if [[ ! "$BRANCH" == "sandbox" ]]
    then
      echo "We only deploy the 'sandbox' branch to the $CF_SPACE cf space"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi

fi

# Set environment variables to be fed into manifest.yml file, that is generated.
VAULT_ENV="$CF_SPACE"
SET_MEMORY="1000M"

cd "$SCRIPT_PATH" || exit

# login and target space
cf login -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -a "$CF_API_ENDPOINT" -s "$CF_SPACE"
cf target -o "$CF_ORG" -s "$CF_SPACE"

# generate manifest and add
sed "s/CF_SPACE/$CF_SPACE/g" manifest-template.yml | sed "s/VAULT_ENV/$VAULT_ENV/g" | sed "s/SET_MEMORY/$SET_MEMORY/g" > "$CF_SPACE.manifest.yml"

# push API
cd .. || exit

# CF Push
cf push conclave-cii-"$CF_SPACE" --strategy rolling -f CF/"$CF_SPACE".manifest.yml
