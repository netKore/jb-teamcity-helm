#!/bin/bash
#Script for testing purposes only
HOST=""
USER=""
PASSWORD=""

export PGPASSWORD=$PASSWORD
kind delete cluster 
rm -rf /tmp/www/*
rm -rf /tmp/www/.teamcity
psql --host=$HOST --username=$USER --dbname=postgres -c "DROP SCHEMA public CASCADE;"
psql --host=$HOST --username=$USER --dbname=postgres -c "CREATE SCHEMA public;"
unset PGPASSWORD


