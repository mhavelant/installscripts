<?php

/**
 * @file
 * Local settings.
 *
 * Database set up for docker4drupal.
 * Config and private files are set up inside the git root,
 * but outside the webroot.
 */

$databases['default']['default'] = array(
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'host' => 'mariadb',
  'port' => '3306',
  'driver' => 'mysql',
  'prefix' => '',
  'collation' => 'utf8mb4_general_ci',
);

$config_directories[CONFIG_SYNC_DIRECTORY] = '../config/prod';
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = '../private_files';
