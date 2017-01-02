# MariaDB Docker Container

This service creates a MariaDB installation (with TokuDB enabled) on a Centos 7 base image. It allows you to set the root password and
(optionally) an additional user/password/database to initialize.
 
# Installation
 
Docker and Docker-Compose are required to run this application, which are packaged 
together for Mac and Windows users into [Docker Toolbox](https://www.docker.com/products/docker-toolbox),
for Linux users, follow the instructions for installing  the 
[Docker Engine](https://docs.docker.com/engine/installation/) and [Docker Compose](https://docs.docker.com/compose/install/).

# Building the MariaDB service
 
After installing the Docker dependencies, run the following from the command line 
at the root of this directory :

```
make docker
```

That command will build an image (using the `Dockerfile` "recipe" in this project folder) from which containers can be created.

To install TokuDB is slightly different than MariaDB. Although much of this process is built into this docker image, one change requires a change made on the host operating system. There is a setting that needs to be disabled (which may already be disabled), please [follow these instructions](https://mariadb.com/kb/en/mariadb/enabling-tokudb/#check-for-transparent-hugepage-support-on-linux) to determine if the setting needs to be turned off on your host machine.

# Running the Container

This container can be run from the command line like this:

```bash
docker run --name=centosmariadbtoku-data -v /var/lib/mysql arizonatribe/centosmariadbtoku /bin/bash
docker run --name=centosmariadbtoku -d --volumes-from=mariadb-data -e MYSQL_ROOT_PASSWORD=<password> arizonatribe/centosmariadbtoku
```

Those commands build a data container (to persist the data in a docker volume) 
as well as the mariadb containerized service. It is linked to the data container (which was exposed as a 
docker volume). The service also has a root password passed in as an environment
variable (see below for additional variables that can be set). Additionally, you can map a volume on your host where you store any database restore scripts.

The `mysqld` service has many additional command-line options to fine-tune the service
and due to the way this docker image is configured, you can pass any of those options
to this container as if you were passing them to the `mysqld` CLI directly. Just
pass a command to override the default "optionless" `mysqld_safe` command, placing
them at the end of the `docker run` command listed above, for example:

```bash
docker run --name=centosmariadb -d --build-arg MARIA_VERSION=10.0.25 --volumes-from=mariadb-data -v $PWD/logs=/var/log -e MYSQL_ROOT_PASSWORD=<password> -p 3306:3306 centosmariadbtoku mysqld_safe --log-error=/var/log/mysql.err --pid-file=/var/run/mysqld.pid
```
These options are more easily committed to a `docker-compose.yml` file if they become this lengthy.
The settings from the previous commands would appear in a `docker-compose.yml` file like this:

```yaml
version: '2'
services:
  mariadb-data:
    image: busybox
    volumes:
      - /var/lib/mysql
      - /var/log
    command: echo Data volume for db
  mariadb:
    build: 
      context: ./
      args:
        - MARIA_VERSION=10.1.13
    image: arizonatribe/centosmariadbtoku:latest
    container_name: centosmariadbtoku
    env_file: .env
    volumes_from:
      - mariadb-data
    volumes:
      - ./logs:/var/log
    ports:
      - 3306:3306
```

This file (if placed in the same directory as the Dockerfile, as indicated by the `build: ./` line)
would be executed from the command line from the project root directory:

```bash
docker-compose up --build
```

This builds the image(s) first, and then instantiates the two containers together. If you wish to
separate building and running into different commands, you can do so too:

```bash
docker-compose build
docker-compose up
```
 
# Administration 

Once your container is up and running, you can log into it manually using the `docker exec` command:

```bash
docker exec -it centosmariadbtoku /bin/bash
```

Now you should be presented with a shell and you can log into your database:

```bash
mysql --protocol=tcp -u root -pmyrootpassword
```

Alternatively, if you have a database script to run, you can execute that script from inside this shell. The way you do that is letting this container know about the directory that contains those scripts on your host. You accomplish this by specifying a volume, which is simply a directory on your host that maps to a directory inside the container (see the `docker-compose` and `docker run`). If you have done this step, you can then execute a command like this from inside this container:

```bash
source /db-scripts/mycustomscript.sh
```

# Environment variables

* __MYSQL_ROOT_PASSWORD__ - The (required) root user password.
* __MYSQL_ALLOW_EMPTY_PASSWORD__ - An boolean value that must be set to `true` if the root password is not being provided to the container. 
* __MYSQL_DATABASE__ - A database to create.
* __MYSQL_USER__ - A non-root user to set up (must also include a password).
* __MYSQL_PASSWORD__ - A password for the non-root user being set up.
* __MARIA_VERSION__ - When _building_ the image, you can set a version corresponding with those found at http://yum.mariadb.org (defaults to 10.0.25 and be warned, in later versions of MariaDB the TokuDB was a separate add-on, so this container will not work with those versions)

__Note__: It is recommended to place these sensitive environment variables for database name, root password, and an additional user account (username and password) into a file named `.env` in the same directory as this repo. As shown in the docker-compose example above, you can point towards that environment file easily before you first build and run your container.
