#!/bin/bash

set -e

CONFIG_FILE="ha_kind"
HELM_RELEASE_NAME="teamcity-ha"
CHART_PATH="./teamcity-ha"

print_help() {
  cat <<EOF
Usage: $0 [--cert <path_to_cert>] | [--token <path_to_token>] | [--anonymous] | [--help]

This script creates a KIND cluster and installs TeamCity with the specified authentication method.

  --cert <path_to_cert>
      Use a certificate for GitHub authentication.
      Example: $0 --cert ./certs/gh.key

  --token <path_to_token>
      Use a token for GitHub authentication.
      Example: $0 --token ./certs/token

  --anonymous
      Install without any authentication (anonymous GitHub access).

  --help
      Show this help message and exit.
EOF
}

# Check arguments
if [[ $# -eq 0 ]]; then
  echo "Error: no arguments provided. Use --help for usage."
  exit 1
fi

AUTH_MODE=""
AUTH_VALUE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cert)
      if [[ -n "$AUTH_MODE" ]]; then
        echo "Error: multiple authentication methods specified. Use only one."
        exit 1
      fi
      AUTH_MODE="cert"
      AUTH_VALUE="$2"
      if [[ -z "$AUTH_VALUE" ]]; then
        echo "Error: no certificate file path provided."
        exit 1
      fi
      shift 2
      ;;
    --token)
      if [[ -n "$AUTH_MODE" ]]; then
        echo "Error: multiple authentication methods specified. Use only one."
        exit 1
      fi
      AUTH_MODE="token"
      AUTH_VALUE="$2"
      if [[ -z "$AUTH_VALUE" ]]; then
        echo "Error: no token file path provided."
        exit 1
      fi
      shift 2
      ;;
    --anonymous)
      if [[ -n "$AUTH_MODE" ]]; then
        echo "Error: multiple authentication methods specified. Use only one."
        exit 1
      fi
      AUTH_MODE="anonymous"
      shift
      ;;
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Create KIND cluster
sudo kind create cluster --config="$CONFIG_FILE"

# Deploy ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

echo "Waiting for ingress controller to become ready (approx. 2 minutes)..."
sleep 120

# Install Helm chart
case "$AUTH_MODE" in
  cert)
    if [[ ! -f "$AUTH_VALUE" ]]; then
      echo "Error: certificate file not found: $AUTH_VALUE"
      exit 1
    fi
    CERT_B64=$(base64 -w 0 < "$AUTH_VALUE")
    helm install "$HELM_RELEASE_NAME" "$CHART_PATH" \
      --set "teamcity.vcsRootConfiguration.ghAccess.configuration.certAuth.cert=$CERT_B64"
    ;;
  token)
    if [[ ! -f "$AUTH_VALUE" ]]; then
      echo "Error: token file not found: $AUTH_VALUE"
      exit 1
    fi
    TOKEN=$(<"$AUTH_VALUE")
    helm install "$HELM_RELEASE_NAME" "$CHART_PATH" \
      --set "teamcity.vcsRootConfiguration.ghAccess.configuration.tokenAuth.token=$TOKEN"
    ;;
  anonymous)
    helm install "$HELM_RELEASE_NAME" "$CHART_PATH"
    ;;
  *)
    echo "Error: no valid authentication mode selected."
    exit 1
    ;;
esac

# Clean up sensitive environment variables
unset PGPASSWORD
