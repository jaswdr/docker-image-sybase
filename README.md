# Sybase SQL Anywhere &copy;
> Docker image to run an instance of SQL Anywhere database

### How to use this image

Run the demo instance that comes with the default instalation:

```sh
$ docker run -d jaschweder/sybase
```
This start a new instance, try connect to the `demo` database in the container and pass `dba` as user and `sql` as password

### Start your own instance

To start your own instance of database file you need to create a volume and pass the file as parameter, see bellow:
```sh
$ docker run -d -v /path/to/database/file/file.db:/srv/data -w /srv/data jaschweder/sybase /srv/data/file.db
```

### Author

This repository is maintained by Jonathan A. Schweder <jonathanschweder@gmail.com>

### Bugs

Found any bug ? please, open an issue [in this page](https://github.com/jaschweder/docker-image-sybase/issues)
