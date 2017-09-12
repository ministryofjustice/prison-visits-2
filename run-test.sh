#!/bin/bash
# wait-for-postgres.sh

set -eo pipefail

RAILS_ENV=test bin/rake db:create
xvfb-run bin/rake
