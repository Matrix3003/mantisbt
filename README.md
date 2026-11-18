Mantis Bug Tracker (MantisBT)
=============================

[![Build Status](https://github.com/mantisbt/mantisbt/actions/workflows/mantisbt.yml/badge.svg?branch=master)](https://github.com/mantisbt/mantisbt/actions/workflows/mantisbt.yml)
[![Gitter](https://img.shields.io/gitter/room/mantisbt/mantisbt.svg?logo=gitter)](https://gitter.im/mantisbt/mantisbt)

Screenshots
-----------

![Screenshot of View Issues page](doc/modern_view_issues.png)

![Screenshot of My View page](doc/modern_my_view.png)

![Screenshot of View Issue Details page](doc/modern_view_issue.png)

Documentation
-------------

For complete documentation, please read the administration guide included with
this release in the `doc/<lang>` directory.  The guide is available in text, PDF,
and HTML formats.

Requirements
------------

* MySQL 5.5.35+, PostgreSQL 9.2+, or other supported database
* PHP 8.1.0+
* a webserver (e.g. Apache or IIS)

Please refer to section 2.2 in the administration guide for further details.

Installation
------------

* Extract the tarball into a location readable by your web server
* Open your browser and navigate to `https://example.com/mantisbt/admin/check/index.php` to verify
  that your web server is compatible with MantisBT and configured correctly.
* Open your browser and navigate to `https://example.com/mantisbt/admin/install.php` to start the
  database installation process.
* Select the database type and enter the credentials to access the database
* Click install/upgrade
* Installation is complete -- you may need to copy the default configuration
  to `mantisbt/config/config_inc.php` if your web server does not have write access
* Remove the `admin` directory from within the MantisBT installation path. The
  scripts within this directory should not be accessible on a live MantisBT
  site or on any installation that is accessible via the Internet.

Docker Compose
--------------

The included Compose setup builds this checkout with PHP and Apache and runs
MariaDB in a separate container. Install Docker and the Compose plugin first.

1. Copy `.env.example` to `.env` and replace both database passwords with
   different strong passwords. Use simple alphanumeric passwords to avoid
   Compose interpolation issues. Keep `.env` private.
2. Set `MANTIS_INSTALLER_ENABLED=1` in `.env`, then run:

   ```sh
   docker compose up -d --build
   ```

3. Open `http://localhost:8080/admin/install.php` on the Docker host. If Docker
   runs on a remote ZimaOS server, use an SSH tunnel, for example
   `ssh -L 8080:127.0.0.1:8080 user@server`, and open that URL on your
   computer. Keep the installer private: anyone who can reach it can change
   the installation.
4. In the installer, select **MySQL Improved** and enter hostname `db`,
   database `bugtracker`, username `mantis`, and the `MANTIS_DB_PASSWORD`
   value from `.env`. Leave the database admin username and password blank
   to use the same user; the database already exists. Complete all installer
   steps and confirm that the configuration file was written successfully.
5. Set `MANTIS_INSTALLER_ENABLED=0` in `.env` and run
   `docker compose up -d` to recreate the app with `/admin` blocked. Log in
   with the initial `administrator` / `root` account and immediately change
   its password.

The app is bound to the server's loopback interface by default. Once setup is
complete, set `MANTIS_BIND_ADDRESS` to the desired server interface (or
`0.0.0.0` for all interfaces) and run `docker compose up -d` to allow network
access. Use a firewall and HTTPS reverse proxy before exposing it publicly.
If the installation URL changes, update `$g_path` in the persistent
`config/config_inc.php` as appropriate. Configure an SMTP server in that file
if you need email notifications; the containers do not provide a mail server.

The `mantis-db` and `mantis-config` volumes persist the database and generated
configuration, including the crypto master salt. Back up both together. File
attachments are stored in the database by default; if configured to use disk,
add and back up a persistent upload volume. Changing passwords in `.env` after
the database has been initialized does not change existing database accounts
or the saved MantisBT configuration. For upgrades, back up first, rebuild the
image, temporarily enable the installer to run the database upgrade, then
disable it again. Do not use `docker compose down -v` unless you intend to
delete the persistent data.

UPGRADING
---------

* Backup your existing installation and database -- really!
* Extract the tarball into a clean directory; do not extract into an existing
  installation, as some files have been moved or deleted between releases
* Copy your configuration from the old installation to the new directory,
  including `config_inc.php`, `custom_strings_inc.php`, `custom_relationships_inc.php`,
  `custom_functions_inc.php` and `custom_constants_inc.php` if they exist
* Point your browser to `https://example.com/mantisbt/admin/check/index.php` to ensure that
  your webserver is compatible with MantisBT and configured correctly
* Point your browser to `https://example.com/mantisbt/admin/install.php` to upgrade
  the database schema
* Click install/upgrade
* Remove the `admin` directory from within the MantisBT installation path. The
  scripts within this directory should not be accessible on a live MantisBT
  site or on any installation that is accessible via the Internet.
* Upgrading is complete

CONFIGURATION
-------------

This file contains information to help you customize MantisBT.  A more
detailed doc can be found at https://www.mantisbt.org/docs/

* `config_defaults_inc.php`
  * this file contains the default values for all the site-wide variables.
* `config/config_inc.php`
  * You should use this file to change config variable values.  Your
    values from this file will be used instead of the defaults.  This file
    will not be overwritten when you upgrade, but config_defaults_inc.php will.
    Look at `config/config_inc.php.sample` for an example.

* `core/*_api.php` - these files contains all the API library functions.

* global variables are prefixed by `g_`
* parameters in functions are prefixed with `p_` -- parameters shouldn't be modified within the function.
* form variables are prefixed with `f_`
* variables that have been cleaned for db insertiong are prefixed with `c_`
* temporary variables are prefixed with `t_`.
* count variables have the word `count` in the variable name

More detail can be seen in the coding guidelines at:
https://www.mantisbt.org/guidelines.php

* The files are split into three basic categories, viewable pages,
  include files and pure scripts. Examining the viewable pages (suffix `_page`)
  should make the basic file format fairly easy to see.  The file names
  themselves should make their purpose apparent.  The approach used is to break the
  work into many small files rather than have a small number of really
  large files.

* You can set `$g_top_include_page` and `$g_bottom_include_page`
  to alter what should be visible at the top and bottom of each page.

* All files were edited with TAB SPACES set to 4.
