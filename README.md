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

cp app/config/config.local.neon.example app/config/config.local.neon

cp docker-compose.override.example.yml docker-compose.override.yml
```

No changes are required if you want to run application as it is.

Note: nginx web application runs on the port 80. Make sure this port is not used, otherwise you will encounter error like this (when initializing Docker):

```
ERROR: for nginx  Cannot start service nginx: Ports are not available: listen tcp 0.0.0.0:80: bind: address already in use
```

In such case, change port mapping in `docker-composer.override.yml`. For example, the following setting maps internal port 80 to external port 8080, so the application will be available at http://mailer.press:8080.
```yaml
services:
# ...
  nginx:
    ports:
      - "8080:80"
```




2. Setup host 

Default host used by application is `http://mailer.press`.
It should by pointing to localhost (`127.0.0.1`), so add this to your local `/etc/hosts` file. 
In addition, please add MailHog as a default email testing tool. Use the following commands: 



```bash
echo '127.0.0.1 mailer.press' | sudo tee -a /etc/hosts
echo '127.0.0.1 mailog.press' | sudo tee -a /etc/hosts
```

3. Perform initialization of `mailer` container

Start container using `docker-compose`:
```
docker-compose up mailer
```

You should see log of starting containers. Now enter the application docker container:

```bash
# run from the same folder as `docker-compose`
docker-compose exec mailer /bin/bash
```

When inside the container, choose and run one of the two installation options:

- Fully ready application with demo data:

```bash
make install-demo
```

- No demo data:

```bash
make install
```

5. Restart containers

Stop all running containers and run `docker-compose up` again. All containers should start, including service containers. 

6. Log-in to Mailer

Access application via web browser. Default configuration:

- URL: http://mailer.press/
- User:
    - Email: `admin@admin.sk`
    - Password: `passphrase_change_me`
    
**IMPORTANT:** Please run step 3 every time you update Mailer-skeleton using `composer update`.

### Manual installation

Clone this repository and run the following commands inside the project folder:

```bash
# 1. Download PHP dependencies
composer install

# 2. Build JS and assets
make js

# 3. Run migrations
php bin/command.php migrate:migrate

# 4. Run seeders
php bin/command.php db:seed
php bin/command.php demo:seed # optional
```

You can override any default config from
[`config.neon`](./app/config/config.neon) by creating file
`config.local.neon` and setting your own values.

#### Dependencies

- PHP 7.4
- MySQL 8
- Redis 3.2