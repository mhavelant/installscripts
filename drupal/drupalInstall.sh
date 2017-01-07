#!/usr/bin/env sh

# Helper script for installing D8 in.
# Note: This should run in the docker container.

printf "Installing drupal.. \n"
drush site-install --site-name="${1}" --site-mail=dev+"${1}"@brainsum.com --account-pass=123 minimal -y \
    && printf "\n Access your site at localhost:8000. \n" \
    || {
        printf "\n Something went wrong. Exiting. \n" \
        && exit 1;
    }

# @todo: Preconfig the site (adminimal toolbar, bartik+seven themes, remove unneeded blocks, etc.)
# @todo: Maybe search for the config/prod/site settings for the uuid, set it here and cim?

exit