# SAP Sybase Anywhere 16

#### Getting started

```
docker run jaschweder/sybase -p 2638:2638
```

Then connect to hostname `localhost` or `127.0.0.1` at port `2638`

#### Environment Variables

##### Guest user
Environment variable | Default value
--- | --- 
SYBASE_USER | guest 
SYBASE_PASSWORD | guest1234 
SYBASE_DB | guest

##### Admin user
Environment variable | Default value
--- | --- 
SYBASE_USER | sa
SYBASE_PASSWORD | sql

##### DBA user
Environment variable | Default value
--- | --- 
SYBASE_USER | dba
SYBASE_PASSWORD | sql

> You can use both `sa` and `guest` users to connect to `guest` database

See more about this image at [Docker Hub](https://hub.docker.com/r/jaschweder/sybase)
