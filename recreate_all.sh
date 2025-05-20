#!/bin/bash

HOST="10.0.2.15"
USER="postgres"
PASSWORD="qazwsx"

export PGPASSWORD=$PASSWORD
kind delete cluster 
rm -rf /tmp/www/*
rm -rf /tmp/www/.teamcity
psql --host=$HOST --username=$USER --dbname=postgres -c "DROP SCHEMA public CASCADE;"
psql --host=$HOST --username=$USER --dbname=postgres -c "CREATE SCHEMA public;"
kind create cluster --config=ha_kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
git pull
sleep 120
helm install teamcity-ha ./teamcity-ha --set teamcity.vcsRootConfiguration.ghAccess.configuration.certAuth.cert=$(cat ./certs/gh.key | base64 -w 0)
unset PGPASSWORD


