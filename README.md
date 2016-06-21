# Oracle docker image by eXo Platform 

This is a Oracle image to easily build an Oracle environment for test purposes.

## How to build

- Download the official Oracle 12rc1 installer on the [oracle site](http://www.oracle.com/technetwork/indexes/downloads/index.html#database)
- Put the 2 archives `linuxamd64_12102_database_1of2.zip` and `linuxamd64_12102_database_2of2.zip` in the `installer` directory
- Execute `docker build -t oracle:12rc1 .`. It will create the image and install Oracle on it. it can take some time.

## How to run

The Oracle instance can be launched with this command :
``` 
docker run --name my-database -p 1521:1521 -e ORACLE_SID=sid -e ORACLE_DATABSE=mydb -e ORACLE_USER=user -e ORACLE_PASSWORD=password -e ORACLE_DBA_PASSWORD=syspassword oracle:12rc1
```

## Variables
All these variables are mandatory :
- ORACLE_SID : The oracle sid used to identified the database
- ORACLE_DATABASE : the name of the database to create
- ORACLE_USER : The standard user name allowed to connect to the database
- ORACLE_PASSWORD : The password of the user 
- ORACLE_DBA_PASSWORD : Administrator password