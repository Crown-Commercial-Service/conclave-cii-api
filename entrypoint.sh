#!/bin/sh
set -e

# Run the rake task to update gca changes only a fix for lower env and will remove
echo "Running database gca changes"
bundle exec rake ccs_to_gca:update_seeds

echo "Starting Rails Server..."
exec "$@"