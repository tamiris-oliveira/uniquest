#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Download CockroachDB SSL certificate
curl --create-dirs -o $HOME/.postgresql/root.crt 'https://cockroachlabs.cloud/clusters/8625936b-a761-46e9-bc75-1f03c730303d/cert'

# Run database migrations
bundle exec rails db:migrate:status
bundle exec rails db:migrate
bundle exec rails db:seed
