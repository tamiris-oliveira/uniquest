#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for Render deployment
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Force migration execution for course_id column
bundle exec rails db:migrate:status
bundle exec rails db:migrate VERSION=20250827142226
bundle exec rails db:migrate
bundle exec rails db:seed
