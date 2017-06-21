# Oracle docker image by eXo Platform

This is a Oracle image to easily build an Oracle environment for test purposes.

## How to build

- Download the official Oracle 12rc1 installer on the [oracle site](http://www.oracle.com/technetwork/indexes/downloads/index.html#database)
- Put the 2 archives `linuxamd64_12102_database_1of2.zip` and `linuxamd64_12102_database_2of2.zip` in the `installer` directory
- Execute `docker build -t <image name>:<tag> .`. It will create the image and install Oracle on it. it can take some time.

## How to run

A build of the image is available on the [docker hub](https://hub.docker.com/r/exoplatform/oracle/).

The Oracle instance can be launched with this command :
```
docker run --name my-database -p 1521:1521 -e ORACLE_SID=sid -e ORACLE_DATABASE=mydb -e ORACLE_USER=myuser -e ORACLE_PASSWORD=mypassword -e ORACLE_DBA_PASSWORD=syspassword exoplatform/oracle:12cR1
```

This will launch Oracle and initialize the database.
The data are persisted on the directory `/u01/app/oracle/data`. To keep them between 2 container restarts, add this parameter to your command line:
```
-v local_datadir:/u01/app/oracle/data
```

## Variables
- ORACLE_SID : The oracle sid used to identified the database (mandatory)
- ORACLE_DATABASE : the name of the database to create (mandatory)
- ORACLE_USER : The standard user name allowed to connect to the database (mandatory)
- ORACLE_PASSWORD : The password of the user (mandatory)
- ORACLE_DBA_PASSWORD : Administrator password (mandatory)
- ORACLE_PGA_TARGET : the memory used by the Program Global Area (default: 512m)
- ORACLE_SGA_TARGET : the memory used by the System Global Area (default: 512m)

## Quick test

As the database initialization can take a long time, for quick tests and if you don't need to keep the data between two restarts, an image with a pre-initialized database is available

```
docker run --rm --name my-database -p 1521:1521  exoplatform/oracle:12cR1_plf
```

The parameters are :
  - ORACLE_USER : plf
  - ORACLE_PASSWORD : plf
  - ORACLE_DATABASE : plf
  - ORACLE_SID : plf
