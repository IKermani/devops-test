# WP-PMA Chart

This chart adds `bitnami/wordpress` and `bitnami/phpmyadmin` as dependencies and customize these parent charts in it's own `values.yaml` file.

## WordPress

As needed in the test's description, Wordpress should be hosted on `/wordpress` path so this chart has been configured with custom post init script which changes `WP_HOME` and `WP_SITEURL` values in `wp-config.php` to generate the URLs in proper format.
Furthermore, the ingress object is configured with rewrite rule to route the paths properly. MariaDB is the default database configured for Wordpress application.


## PHPMyAdmin

Similar to Wordpress, the path of PMA should be on `/dbadmin` so the proper rewrite rule is written for it's ingress. Also it is configured to connect to the MariaDB by default.

In addition, the `PHPMYADMIN_ABSOLUTE_URI` environment variable is configured for PMA to generate proper links as it is hosted in `/dbadmin` path.

