# REMP Mailer Skeleton

This is a pre-configured skeleton of REMP Mailer application with simple installation.

Mailer serves as a tool for configuration of mailers, creation of email layouts and
templates, and configuring and sending mail jobs to selected segments of users.

## Installation

### Docker

The simplest possible way is to run this application in docker containers. Docker Compose is used for orchestrating. Except of these two application, there is no need to install anything on host machine.

Recommended _(tested)_ versions are:

- [Docker](https://www.docker.com/products/docker-engine) - 24.0.4
- [Docker Compose](https://docs.docker.com/compose/overview/) - 2.19.1

#### Steps to install application within docker

1. Get the application 

    A) Using Composer:
    ```bash
    composer create-project --no-install remp/mailer-skeleton path/to/install
    ```
    ```bash
    cd path/to/install
    ```

    B) Using GitHub:
    ``` bash
    git clone https://github.com/remp2020/mailer-skeleton.git
    ```

    ```bash
    cd mailer-skeleton
    ```

2. Prepare environment & configuration files
    ```bash
    cp .env.example .env
    ```
    ```bash
    cp app/config/config.local.neon.example app/config/config.local.neon
    ```
    ```bash
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

4. Setup host 

    Default host used by application is `http://mailer.press`.
    This domain should by pointing to localhost (`127.0.0.1`), so add it to local `/etc/hosts` file. 
   In addition, we recommend adding  `mailhog.mailer.press` domain for testing. Use the following commands:
    
    ```bash
    echo '127.0.0.1 mailer.press' | sudo tee -a /etc/hosts
    ```
    ```bash
    echo '127.0.0.1 mailhog.mailer.press' | sudo tee -a /etc/hosts
    ```

5. Start Docker containers

    ```bash
    docker compose up
    ```
    
    You should see logs of starting containers. This may include errors, because application was not yet initialized.
    Enter the application docker container:
    
    ```bash
    # run from anywhere in the project
    docker compose exec mailer bash
    ```
    
    When inside the container, add required permissions:
    
    ```bash
    chmod -R a+rw temp log
    ```
    
    After that, choose and run one of the two installation options:
    
    - Fully ready application with demo data:
    
        ```bash
        make install-demo
        ```
    
    - No demo data:
    
        ```bash
        make install
        ```

6. Log-in to Mailer

    Access application via web browser. Default configuration:
    
    - URL: http://mailer.press/
    - User:
        - Email: `admin@admin.sk`
        - Password: `passphrase_change_me`
        
    **IMPORTANT:** Please run `make install` every time you update Mailer-skeleton using `composer update`.

### Manual installation

#### Dependencies

- PHP 8.1
- MySQL 8
- Redis 6.2

#### Installation

[comment]: <> (Clone this repository and run the following command inside the project folder:)
Clone this repository, go inside the folder and run the following to create configuration files from the sample ones:

```bash
cp .env.example .env
```
```bash
cp app/config/config.local.neon.example app/config/config.local.neon
```

Edit `.env` file and set up all required values such as database and Redis connections.

Now run the installation:

```bash
make install
```

As an alternative, run the following to include seeding of demo values in the installation:

```bash
make install-demo
```

## Mailer demo overview

### Default integrations

After the installation of Mailer skeleton, Mailer uses default (local) integrations that need to be replaced with real implementations before going live. The local integrations serve as references and defaults to allow sending testing emails without doing any extra work.

#### Authentication

[`SimpleAuthenticator`](https://github.com/remp2020/mailer-module#simple-authenticator) is responsible for authentication to the tool. 

List of credentials is configured in [`config.local.neon`](app/config/config.local.neon) file. Default credentials are:

- Email: `admin@admin.sk`
- Password: `passphrase_change_me`

Do not run Mailer publicly with `SimpleAuthenticator` using the default credentials.

#### Mailers integration

Outgoing emails are sent by `SmtpMailer`. To configure a different mailer (e.g. MailGun), consult the [Mailers section](https://github.com/remp2020/mailer-module#mailers) in the documentation.
Configuration of the SMTP mailer is loaded from `config.local.neon`, see the section `local_configs` (which overrides any configuration options stored in the database):

```yaml
local_configs:
    default_mailer: remp_smtp
    remp_smtp_host: mailhog
    remp_smtp_port: 1025
```

Key `remp_smtp_host` points to `mailhog`. This is an internal docker address of the mailhog docker container. The container runs MailHog, which is a web based SMTP testing tool.
Therefore, all emails sent from the Demo Mailer instance are captured by MailHog, and are easily viewable in the MailHog web interface at [http://mailhog.mailer.press](http://mailhog.mailer.press).

#### User-base integration

Mailer depends on external authority to get information about users. As a default source of users, [`Dummy`](https://github.com/remp2020/mailer-module#dummy-implementation-1) implementation of user provider is used. Provider lists 2 demo users (*foo@example.com*, *bar@example.com*). 
See [the documentation](https://github.com/remp2020/mailer-module#user-integration) on how to implement different user provider.

#### Segment integration

To send a newsletter, Mailer needs to get a segment of users who should receive it. To complement default user-base integration, there's also [`Dummy`](https://github.com/remp2020/mailer-module#dummy-implementation) implementation of segment provider, always returning the same segment with both demo users.

### Debug mode

After the installation, Mailer is running in debug mode and all debug information is shown. **Avoid running this mode in production.** To disable this mode, change the value of `ENV` key in `.env` configuration file: 

```dotenv
# previously was `local` (debug ON)
ENV=production
```

### Basic scenario - send email to user segment

To test the Mailer functionality, we recommend going through the following basic scenario:

1. Log-in to Mailer at URL http://mailer.press
2. Go to [Jobs](http://mailer.press/job) 
4. Click **Add new job** 
5. Select values in **Include segments**, **Newsletter list**, and **Email A alternative** inputs. Keep other inputs empty.
    - Demo values of _Emails_, _Layouts_ and _Newsletter lists_ are seeded by default in demo installation.
6. Click **Save and start** button
7. Wait approximately a minute, so Mailer processes the job. Check the job status at [Jobs](http://mailer.press/job) page.
8. After the job is processed (status "DONE"), go to MailHog at http://mailhog.mailer.press/ and check that emails were successfully received. 

## Customization

Mailer-skeleton is ready for customization. Please see the [mailer-module](https://github.com/remp2020/mailer-module) documentation for more information. 

As a sample, mailer-skeleton provides `app/Commands/SampleCommand.php`, extending the `Command` class. 
It is registered as a new command in the `config.local.neon` file. Run it by connecting to the container:

```bash
docker compose exec mailer bash
```
and executing the command:

```bash
php bin/command.php mail:sample-command
```

## Troubleshooting

Some known errors that have occurred and how to fix them.

#### Docker SMTP error "Cannot assign requested address"

In some cases (such as running containers for the first time), a docker container might end up reporting this error message. Simply restarting the problematic container should help.  





