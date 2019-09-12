## Client (DBeaverEE) cant connect to the Docker container.

Use the hosts ip instead of `localhost` in the "host" section of the connection wizard. Run `ifconfig | grep 'inet ' | grep -v 127.0.0.1` and use the ip shown in the result.

Example:

```
rpacas@Rafaels-MacBook-Pro
 in   ~/Desktop/repos/quasar/quasar/dbt (master) $ ifconfig | grep 'inet ' | grep -v 127.0.0.1
	inet 192.168.0.10 netmask 0xffffff00 broadcast 192.168.0.255
```

In this example. The ip would be `192.168.0.10`.

## A local version of PostgreSQL is already installed and is using the same port `5432` as the image.

Alter the alias that brings the Docker image up and change the Docker host port to `5439`.

Example:

```
docker run --rm --name quasar-pg -e POSTGRES_PASSWORD=postgres -d -p 5439:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data $QUASAR_PG_DOCKER_IMAGE
```

This is the port that you will use when connecting to the PostgreSQL image from your client.
