# Docker Twemproxy (Nutcracker)

Twemproxy (nutcracker) is a lightwieght proxy for memcached and redis.

## Run

There are 2 ways to run the twemproxy container.  A configuration can be dynamically configured through environment variables by specifying the servers (and other parameters) through the `TWEMPROXY_SERVERS` variable.  If you are not specifiying the path to a configuration file, you must at least define `TWEMPROXY_SERVERS`.  A full list of configuration options are listed below.

```
docker run -p 11211 -p 22222 \
  -e 'TWEMPROXY_SERVERS=127.0.0.1:11311:1,127.0.0.1:11411:1,127.0.0.1:11511:1' \
  -e 'TWEMPROXY_TIMEOUT=10' \
  ctxswitch/twemproxy
```

The other way to start up twemproxy is to specify the TWEMPROXY_CONFIG variable to reference a config that has been prebaked into a container image or added to the image as part of it's initialization process in a scheduling framework such as Kubernetes or Marathon.

```
docker run -p 11211 -p 22222 \
  -e 'TWEMPROXY_CONFIG=/path/to/nutcracker.yml' \
  ctxswitch/twemproxy
```

## Environment Variables

### Nutcracker command options

* `TWEMPROXY_VERBOSE`: Verbosity of nutcracker logging from 0 to 11.  Default 5.
* `TWEMPROXY_STATS_PORT`: The port to expose stats on.  Default 22222.
* `TWEMPROXY_STATS_ADDRESS`: The address to expose stats on.  Default 127.0.0.1.
* `TWEMPROXY_STATS_INTERVAL`: The stats aggregation interval in msec.  Default 30000.
* `TWEMPROXY_MBUF_SIZE`: Size of mbuf chunk in bytes.  Default 16384.

### Static pool configuration options

* `TWEMPROXY_CONFIG`: The path to a configuration artifact that has been added to the container.  It is not set by default.

### Dynamic pool configuration options

* `TWEMPROXY_LISTEN`: The host:port combination to listen on.  Default `127.0.0.1:11211`.
* `TWEMPROXY_HASH`: The name of the hash function.  Default fnv1a_64.
* `TWEMPROXY_DISTRIBUTION`: The key distribution mode.  Default ketama.
* `TWEMPROXY_AUTO_EJECT_HOSTS`: Whether or not a host should be temporarily ejected on failure.  Default true.
* `TWEMPROXY_SERVER_RETRY_TIMEOUT`: The timeout value in msec to wait before retrying and ejected host. Default 30000 msec.
* `TWEMPROXY_SERVER_FAILURE_LIMIT`: The number of failures that would lead to a host being temporarily ejected.  Default 2.
* `TWEMPROXY_TIMEOUT`: The timeout value in msec to wait for a connection to a server.  Default 60000 msec.
* `TWEMPROXY_BACKLOG`: The TCP backlog argument.  Default 512.
* `TWEMPROXY_PRECONNECT`: Whether or not twemproxy should pre-connect to all servers in the pool on startup.  Default false.
* `TWEMPROXY_REDIS`: Whether or not the pools speaks as Redis.  Default false.
* `TWEMPROXY_REDIS_DB`: The redis db number.  There is no default and is only used when `TWEMPROXY_REDIS` is set to true.
* `TWEMPROXY_REDIS_AUTH`: Authenticate to the Redis server on connect.  There is no default and is only used when `TWEMPROXY_REDIS` is set to true.
* `TWEMPROXY_SERVERS`: A comma seperated list of server:port:priority entries to use in the `servers` block of the nutcracker configuration.
