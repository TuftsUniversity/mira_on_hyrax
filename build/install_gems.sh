#!/bin/sh

if [ "${RAILS_ENV}" = 'production' ] || [ "${RAILS_ENV}" = 'staging' ]; then
  echo "Bundle install without development or test gems."
  bundle install
else
  bundle install
fi
