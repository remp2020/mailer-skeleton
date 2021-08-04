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

**Note:** nginx web application runs on the port 80. Make sure this port is not used, otherwise you will encounter error like this when initializing Docker:

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
Use the following command:

```bash
echo '127.0.0.1 mailer.press' | sudo tee -a /etc/hosts
```

3. Perform initialization of `mailer` container

Start container using `docker-compose`:
```
docker-compose up mailer
```

You should see logs of starting containers. Now enter the application docker container:

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

Stop all running containers and run:

```bash
docker-compose up
``` 

All containers should start, including service containers (cron and workers). 

6. Log-in to Mailer

Access application via web browser. Default configuration:

- URL: http://mailer.press/
- User:
    - Email: `admin@admin.sk`
    - Password: `passphrase_change_me`
    
**IMPORTANT:** Please run step 3 every time you update Mailer-skeleton using `composer update`.

### Manual installation

Clone this repository and run the following command inside the project folder:

```bash
make install
```

As an alternative, run the following to include seeding of demo values in the installation:

```bash
make install-demo
```

You can override any default config from
[`config.neon`](./app/config/config.neon) by creating file
`config.local.neon` and setting your own values.

#### Dependencies

- PHP 7.4
- MySQL 8
- Redis 3.2

## Mailer demo overview

After the installation of Mailer-skeleton, the following defaults are used.

[`SimpleAuthenticator`](https://github.com/remp2020/mailer-module#simple-authenticator) is responsible for authentication to the tool. 
List of credentials is configured in `config.local.neon` file. Default credentials are:
- Email: `admin@admin.sk`
- Password: `passphrase_change_me`  

As a source of users, [`Dummy`](https://github.com/remp2020/mailer-module#dummy-implementation-1) implementation of user provider is used. Provider provides list of 2 demo users (*foo@example.com*, *bar@example.com*). 
See [the documentation](https://github.com/remp2020/mailer-module#user-integration) on how to implement different user provider. 

Outgoing emails are sent by `SmtpMailer`. To configure a different mailer (e.g. MailGun), consult the [Mailers section](https://github.com/remp2020/mailer-module#mailers) in the documentation.
Configuration of the SMTP mailer is loaded from `config.local.neon`, see the section `local_configs` (which overrides any configuration options stored in the database):

```yaml
local_configs:
    default_mailer: remp_smtp
    remp_smtp_host: mailhog
    remp_smtp_port: 1025
```

Key `remp_smtp_host` points to `mailog`. This is an internal docker address of the mailhog docker container. The container runs MailHog, which is a web based SMTP testing tool.
Therefore, all emails sent from the Demo Mailer instance are captured by MailHog, and are easily viewable in the MailHog web interface at URL [http://mailhog.mailer.press](http://mailhog.mailer.press).

### Basic scenario - send email to user segment

To test the Mailer functionality, we recommend going through the following basic scenario:

1. Log-in to Mailer at URL http://mailer.press
2. Go to [Jobs](http://mailer.press/job) page and click **Add new job**
3. Select values in **Segment** and **Email A alternative** inputs. Keep other inputs empty.
    - Demo values of _Emails_, _Layouts_ and _Newsletter lists_ are seeded by default.
4. Click **Save and start** button
5. Wait approximately a minute, so Mailer processes the job. Check the job status at [Jobs](http://mailer.press/job) page.
6. After the job is processed (status "DONE"), go to MailHog at http://mailhog.mailer.press/ and check that emails were successfully received. 

## Customization

Mailer-skeleton is ready for customization. Please see the [mailer-module](https://github.com/remp2020/mailer-module) documentation for more information. 

As a sample, mailer-skeleton provides `app/Commands/SampleCommand.php`, extending `Command` class. 
It is registered as a new command in `config.local.neon` file. Run it by connecting to the container:

```bash
docker-compose exec mailer /bin/bash
```
and executing the command:

```bash
php bin/command.php mail:sample-command
```






