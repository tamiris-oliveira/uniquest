#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Reset database step by step for CockroachDB
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:schema:drop
bundle exec rails db:migrate
bundle exec rails db:seed
