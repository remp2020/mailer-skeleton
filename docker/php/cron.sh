#!/bin/sh

# Run process-job manually once, so Mailer has flag it's running (and doesn't have wait minute for it)
php /var/www/html/bin/command.php mail:process-job

# Run cron in foreground
cron -f