#!/bin/bash

HOST="10.0.2.15"
USER="postgres"
PASSWORD="qazwsx"

export PGPASSWORD=$PASSWORD
kind delete cluster 
rm -rf /root/www/*
rm -rf /root/www/.teamcity
psql --host=$HOST --username=$USER --dbname=postgres -c "DROP SCHEMA public CASCADE;"
psql --host=$HOST --username=$USER --dbname=postgres -c "CREATE SCHEMA public;"
kind create cluster --config=ha_kind
git pull
helm install teamcity-ha --generate-name --set teamcity.vcs.password="$1"

unset PGPASSWORD


