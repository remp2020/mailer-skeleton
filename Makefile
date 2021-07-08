#! /usr/bin/make

PHP_FOLDERS=app bin extensions tests

js:
	yarn install
	yarn production

js-dev:
	yarn install
	yarn dev

js-watch:
	yarn install
	yarn watch

sniff:
	php vendor/bin/phpcs --standard=.phpcs_ruleset.xml ${PHP_FOLDERS} -n -p

sniff_fix:
	php vendor/bin/phpcbf --standard=.phpcs_ruleset.xml ${PHP_FOLDERS} -n

syntax:
	find ${PHP_FOLDERS} -name "*.php" -print0 | xargs -0 -n1 -P8 php -l

phpstan:
	php vendor/bin/phpstan analyse --configuration=.phpstan.neon --level=1 --memory-limit=1G app tests extensions
