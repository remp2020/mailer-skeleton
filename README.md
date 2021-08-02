# REMP Mailer Skeleton

This is a pre-configured skeleton of REMP Mailer application with simple installation.

Mailer serves as a tool for configuration of mailers, creation of email layouts and
templates, and configuring and sending mail jobs to selected segments of users.

## Installation

### Docker

The simplest possible way is to run this application in docker containers. Docker Compose is used for orchestrating. Except of these two application, there is no need to install anything on host machine.

Recommended _(tested)_ versions are:

- [Docker](https://www.docker.com/products/docker-engine) - 20.10.5, build 55c4c88
- [Docker Compose](https://docs.docker.com/compose/overview/) - 1.29.0, build 07737305

#### Steps to install application within docker

1. Prepare environment & configuration files
```
cp .env.example .env
```
```
cp app/config/config.local.example.neon app/config/config.local.neon
```
```
cp docker-compose.override.example.yml docker-compose.override.yml
```
No changes are required if you want to run application as it is.

2. Setup host 

Default host used by application is `http://mailer.press`. It should by pointing to localhost (`127.0.0.1`), so add this to your local `/etc/hosts` file. You can use this command:

```bash
echo '127.0.0.1 mailer.press' | sudo tee -a /etc/hosts
```

3. Start `docker-compose`

```
docker-compose up
```

You should see log of starting containers.

4. Enter application docker container

```
docker-compose exec mailer /bin/bash
```

Following commands will be run inside container.

5. Update permissions for docker application

Owner of folders `temp` and `log` is user on host machine. Application needs to have right to write there.

```
mkdir temp log; chmod -R a+rw temp log
```

6. Install composer packages.

```
composer install
```

7. Install and build JS packages.

```
make js
```

8. Initialize and migrate database.

```
php bin/command.php migrate:migrate
```

9. Seed database with required data

```
php bin/command.php db:seed
```

10. (Optional) Seed database with demo data

```
php bin/command.php demo:seed
```

Access application via web browser. Default configuration:

- URL: http://mailer.press/
- User:
    - Email: `admin@admin.sk`
    - Password: `passphrase_change_me`
    
**IMPORTANT:** Please run steps 6-9 every time you update Mailer using `composer update`.

### Manual installation

Clone this repository and run the following commands inside the project folder:

```bash
# 1. Download PHP dependencies
composer install

# 2. Download JS/HTML dependencies
yarn install

# !. use extra switch if your system doesn't support symlinks (Windows; can be enabled)
yarn install --no-bin-links

# 3. Generate assets
make js

# 4. Run migrations
php bin/command.php migrate:migrate

# 5. Run seeders
php bin/command.php db:seed
php bin/command.php demo:seed # optional
```

You can override any default config from
[`config.neon`](./app/config/config.neon) by creating file
`config.local.neon` and setting your own values.

#### Dependencies

- PHP 7.4
- MySQL 5.7
- Redis 3.2