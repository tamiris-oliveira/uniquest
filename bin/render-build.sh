#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate:status
# Force cleanup orphaned migrations first
bundle exec rails db:migrate VERSION=20250829220608
bundle exec rails db:migrate
bundle exec rails db:seed
