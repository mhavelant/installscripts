# Install Scripts
## Overview
These are just some simple scripts to make life easier.

## Requirements
* Ubuntu 16.04
  * Not necessary, but the scripts have only been tested on this OS
* Git
* Composer
* PHP cli (with some extension required by composer, etc.)
* Docker
  * Make sure it runs without sudo and autostart with the system!
* Docker-compose
* sudo permissions

## Scripts
### Docker4Drupal
#### Note: I only tested with the 'yes' argument, this might not work for existing code. Yet.
To install a new Drupal 8 project (drupal-composer) under the docker4drupal environment:  
1. Copy the contents of the "drupal" folder to your "projects" folder
    1. E.g. /var/www
1. Add execute permissions to the main script file
    1. sudo chmod +x docker4drupal.sh
1. Start the script
    1. bash docker4drupal.sh <newProject: yes/no> <siteName: a string without whitespaces>

If the newProject argument is 'yes', the script will 
* try to create a new folder named siteName (if it doesn't exist already)
* create a new drupal-composer/drupal-project project inside the siteName folder
  * Note: If this is the first drupal-composer project on your machine, composer will 
  download the required packages first. That might take a while.
* change permissions for d4d to work
* start the d4d environment
  * Note: If this is the first d4d v1.3.0 project on your machine, this means pulling down
  required docker image. That might take a while.
* install drupal 8 according to the drupalInstall.sh
  * Note: The install will enable modules that I like, 
  you might want to change that (and the composer require stuff as well)
  
If the newProject argument is 'no', the script will behave similarly, with the exception of
creating a new composer project. Permissions, docker launch and drupal install should behave
the same.
    
If the drupalInstall script fails (e.g MySQL refused the connection), 
but everything else went ok, just re-run drupalInstall.
* docker-compose exec --user 82 php sh
* cd web
* ./drupalInstall.sh <siteName>
