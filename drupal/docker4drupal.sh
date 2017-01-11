#!/usr/bin/env sh

# @todo
# 1, Pre-req check (git, docker, composer, docker-compose, php & extensions, etc)
# 2, Add code to prevent the script from continuing when an error occurs.
#    E.g: If composer install fails, abort..
# 3, Add drupalInstallProfile argument?
# 4, Refactor into multiple files? (include, run, etc)

# Install script for Drupal projects under the docker4drupal Docker environment.
# Intended for local development, not production instances.
# It is configured for D8 with PHP7.0 by default.

# Arguments:
# string newProject
#    required argument
#    yes or no are accepted
#    Whether this is a new project (meaning a composer install is needed),
#    or an existing one (no composer install, just permission fixes and D8 install).
#
# string siteName
#    required argument
#    any string is accepted (don't use spaces in it)
#    The name of the project folder and your site.

# Usage
# 1, Go into your "projects" folder, copy the contents of the "drupal" folder there.
# 2, Start the script.

D4DVersion="v1.3.0"
rootDir=${PWD}

# Initial preparation of the project root directory.
PrepareDirectory() {
    printf "Preparing directory.. \n"
    sudo chmod 2775 .
    sudo chgrp -R 82 .
}

# Create a new DrupalComposer project in the current directory.
CreateNewProject() {
    printf "Creating new drupal-composer project (D8).. \n"
    composer create-project drupal-composer/drupal-project:8.x-dev . --stability dev --no-interaction
    mkdir -m 2775 "private_files"
    mkdir -m 2775 -p "config/prod"
    cp "${rootDir}/docker-compose.yml" .
#    @Note: Instead of doing this, I'll just push the modified yml..
#    I'll leave this here for future reference though..
#    wget -O "docker-compose.yml" "https://raw.githubusercontent.com/wodby/docker4drupal/${D4DVersion}/docker-compose.yml"
#    # PHP and nginx docroots should be web for D8.
#    # These EVNVAR-s are commented by default, so we uncomment them.
#    sed -i '/PHP_DOCROOT/s/^#//; /NGINX_DOCROOT/s/^#//' docker-compose.yml
}

# Fix file and folder permissions.
# @todo: Refactor this.
FixPermissions() {
    printf "Fixing file permissions.. \n"
    # @todo: some commands might be redundant.
    find . -type d -exec sudo chmod 2755 {} \;
    # Only the web, so vendor stuff like drush is still usable.
    find web -type f -exec sudo chmod 644 {} \;
    sudo chmod -R 2775 private_files
    # 2777 might be needed for drush cex/git pull to work nicely , needs testing.
    sudo chmod -R 2775 config
    sudo chmod -R 2775 web/sites/default/files
}

# Edits the settings.php so it loads the settings.local.php
EditSettingsPhp() {
    printf "Adding and enabling local settings.. \n"
    # @todo: Check permissions first, you never know..

    cp "${rootDir}/settings.local.php" "web/sites/default"

    targetFile="web/sites/default/settings.php"

     printf "\nif (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {\n" >> ${targetFile}
     printf "  include \$app_root . '/' . \$site_path . '/settings.local.php';\n" >> ${targetFile}
     printf "}\n" >> ${targetFile}
}

RequireComposerPackages() {
    printf "Requiring some stuff I like.. \n"
    # @todo: Adminimal toolbar and whatnot
}

StartDockerContainers() {
    printf "Starting docker containers.. \n"
    docker-compose up -d && docker-compose ps
    # Wait the mariadb container to start properly..
    sleep 6s
}

InstallDrupal() {
    printf "Preparing to install drupal.. \n"
    cp "${rootDir}/drupalInstall.sh" "web"
    sudo chmod +x "web/drupalInstall.sh"
    docker-compose exec --user 82 php sh -c "cd web;./drupalInstall.sh ${siteName}" \
        && printf "Drupal install done.\n" \
        || {
            printf "Something went wrong at the install. Stopping docker.. \n" \
            && docker-compose stop \
            && sudo chmod g+w web/sites/default/settings.php \
            && exit 1;
        }
}

# Initial

printf "Script started from %s \n" "${rootDir}"

# Argument checks..

if [[ $# -eq 0 ]] ; then
    printf "No argument supplied. Required are: newProject (yes/no), siteName (string) \n"
    exit 1
fi

newProject=${1}
siteName=${2}

if [ -z "$newProject" ] ; then
    printf "newProject argument is missing. Add yes or no. \n" && exit 1
fi

if [ "$newProject" != "yes" ] && [ "$newProject" != "no" ] ; then
    printf "Invalid argument ( %s ). Add yes or no. \n" "${newProject}" && exit 1
fi

if [ -z "$siteName" ] ; then
    printf "Site name is required. \n" && exit 1
fi

# Directory check..

if [ ! -d "$siteName" ]; then
    printf "%s\n" "Directory '${siteName}' does not exist. Creating it.."
    mkdir ${siteName} \
        && printf "Done \n" \
        || { printf "Directory creation failed. \n"; exit 1; }
fi

cd ${siteName}

printf "Working directory changed to %s \n" "$PWD"

# Install & Config

PrepareDirectory

if [ "$newProject" == "yes" ] ; then
    printf "New project. \n"
    CreateNewProject
else
    printf "Existing project. Docker-setup and drupal install only. \n"
fi

FixPermissions
EditSettingsPhp
RequireComposerPackages
StartDockerContainers
InstallDrupal
