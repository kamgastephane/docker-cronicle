# docker-cronicle
[![Build status](https://img.shields.io/docker/build/intelliops/cronicle.svg)](https://hub.docker.com/r/intelliops/cronicle) [![Build status](https://img.shields.io/travis/belsander/docker-cronicle/master.svg)](https://travis-ci.org/belsander/docker-cronicle)

Docker container for a Cronicle single-server master node

This repo is based on the work from [nicholasamorim](https://github.com/nicholasamorim/docker-cronicle)

Some useful features were included in order to facile automation and integration into a CI/CD platform.
* automatic creation of account, plugins and apiKeys during initial setup
* default plugin for a mongo db backup with S3 upload
* automatic creation  of events during initial setup
* aws-ci installed by default

# Supported tags

* `latest`, `0.5.0`, [Dockerfile](https://raw.githubusercontent.com/kamgastephane/docker-cronicle/master/Dockerfile)


## latest
Latest version of Cronicle server based upon nodejs Docker image.


# Usage

## Install
```sh
docker pull stepos01/docker-cronicle:latest
```

## Running
```sh
docker run --name cronicle --hostname localhost -p 3012:3012 stepos01/docker-cronicle:latest
```

Alternatively with persistent data and logs:
```sh
docker run --name cronicle \
  -v /path-to-cronicle-storage/data:/opt/cronicle/data:rw \
  -v /path-to-cronicle-storage/logs:/opt/cronicle/logs:rw \
  --hostname localhost -p 3012:3012 stepos01/docker-cronicle:latest
```

The web UI will be available at: http://localhost:3012

> NOTE: please replace the hostname `localhost`, this is only for testing
> purposes! If you rename the hostname also consider setting the environmental
> variable `CRONICLE_base_app_url`.
> e.g `docker run --name cronicle --hostname cronicle-host -p 3012:3012 -e CRONICLE_base_app_url='http://cronicle-host:3012' stepos01/cronicle:latest`

## Volumes
Cronicle process runs under the `cronicle` user with `ID 1001` and `GUID `1001`.  If you are using Docker bind mounts set permissions accordingly.

| Path | Description |
|--------|--------|
| /opt/cronicle/data | Volume for data |
| /opt/cronicle/logs | Volume for logs |
| /opt/cronicle/plugins | Volume for plugins |

## Configuration

### Environmental variables
Cronicle supports a special environment variable syntax, which can specify command-line options as well as override any configuration settings.  The variable name syntax is `CRONICLE_key` where `key` is one of several command-line options (see table below) or a JSON configuration property path.

For overriding configuration properties by environment variable, you can specify any top-level JSON key from `config.json`, or a *path* to a nested property using double-underscore (`__`) as a path separator.  For boolean properties, you can specify `1` for true and `0` for false.  Here is an example of some of the possibilities available:

| Environmental variable | Description | Default value |
|--------|--------|--------|
| CRONICLE_base_app_url | A fully-qualified URL to Cronicle on your server, including the port if non-standard. This is used for self-referencing URLs. | http://localhost:3012 |
| CRONICLE_WebServer__http_port | The HTTP port for the web UI of your Cronicle server. (Keep default value, unless you know what you are doing) | 3012 |
| CRONICLE_WebServer__https_port | The SSL port for the web UI of your Cronicle server. (Keep default value, unless you know what you are doing) | 443 |
| CRONICLE_web_socket_use_hostnames | Setting this parameter to `1` will force Cronicle's Web UI to connect to the back-end servers using their hostnames rather than IP addresses. This includes both AJAX API calls and Websocket streams. | 1 |
| CRONICLE_server_comm_use_hostnames | Setting this parameter to `1` will force the Cronicle servers to connect to each other using hostnames rather than LAN IP addresses. | 1 |
| CRONICLE_web_direct_connect | When this property is set to `0`, the Cronicle Web UI will connect to whatever hostname/port is on the URL. It is expected that this hostname/port will always resolve to your master server. This is useful for single server setups, situations when your users do not have direct access to your Cronicle servers via their IPs or hostnames, or if you are running behind some kind of reverse proxy. If you set this parameter to `1`, then the Cronicle web application will connect directly to your individual Cronicle servers. This is more for multi-server configurations, especially when running behind a load balancer with multiple backup servers. The Web UI must always connect to the master server, so if you have multiple backup servers, it needs a direct connection. | 0 |
| CRONICLE_socket_io_transports | This allows you to customize the socket.io transports used to connect to the server for real-time updates. If you are trying to run Cronicle in an environment where WebSockets are not allowed (perhaps an ancient firewall or proxy), you can change this array to contain the `polling` transport first. Otherwise set it to `["websocket"]` | ["polling", "websocket"]

### Custom configuration file
A custom configuration file can be provide in the following location:
```sh
/path-to-cronicle-storage/data/config.json.import
```
The file will get loaded the very first time Cronicle is started. If afterwards
a forced reload of the custom configuration is needed remove the following file
and restart the Docker container:
```sh
/path-to-cronicle-storage/data/.setup_done
```
A sample config can be found [here](https://github.com/jhuckaby/Cronicle/blob/master/sample_conf/config.json)

### Custom setup file
As mentioned earlier, one of the additional feature is related to automating the creation of users, groups, apiKeys...
We simply need to modify the [setup.json](https://github.com/kamgastephane/docker-cronicle/blob/master/setup.json) provided in this repository

The file will get loaded the very first time Cronicle is started. If afterwards
a forced reload of the custom configuration is needed remove the following file
and restart the Docker container:
```sh
/path-to-cronicle-storage/data/.setup_done
```
A more exhaustive explanation about the possibilities can be found in the following thread:
[Thread on automating cronicle by the author](https://github.com/jhuckaby/Cronicle/issues/12)

#### User
In the `setup.json` file, we can see the creation of an user with username 
`stephane` and password `admin`. This is achieved by updating the
following JSON with
https://github.com/kamgastephane/docker-cronicle/blob/e7982bbf2f342cb54bb687408bc5d9ab8880f8b5/setup.json#L16-L27

Details about values to be used can be found here
[Thread on automating cronicle by the author](https://github.com/jhuckaby/Cronicle/issues/12)

#### Plugins
In the `setup.json` file, we can see the creation of a plugin called
`mongobackup`. 
https://github.com/kamgastephane/docker-cronicle/blob/e7982bbf2f342cb54bb687408bc5d9ab8880f8b5/setup.json#L62-L81
We just need to define the parameters as well as the command line script which should be run.
We can also define a piece of code to be run instead.
A great definition of plugin can be found [here](https://github.com/jhuckaby/Cronicle#plugins)
All the created plugins can be found in the `plugins` folder.

Our events created from the mongo backup plugin expects a few parameters

| Parameter name | Description  |
|--------|--------|
|name| the name of the backup
|uri| the mongo url of the database ( tested with srv format). The utility used for backup is mongorestore.
|aws_access_key_id*| AWS secret key
|aws_secret_access_key*| AWS secret key
|aws_default_region*| AWS default region
|s3_destination| the destination on S3(Could be any bucket or path. e.g: **mybucket/cronicle/mybackups**

*: those parameters are set as **hidden**. So they are added attached to the plugin directly and are assigned a value,
and they cannot be seen nor modified afterwards without rebuilding and redeploying the container.
This is done to avoid exposing private keys on the Cronicle user interface.]

#### Category
In the `setup.json` file, we can see the creation of a category 
called `mongo`. This is achieved by updating the
following JSON with
https://github.com/kamgastephane/docker-cronicle/blob/e7982bbf2f342cb54bb687408bc5d9ab8880f8b5/setup.json#L114-L123

#### ApiKey
In the `setup.json` file, we can see the creation of an API Key.
https://github.com/kamgastephane/docker-cronicle/blob/e7982bbf2f342cb54bb687408bc5d9ab8880f8b5/setup.json#L144-L162
This API key is used to create events automatically through API.
If we decide to change the value of the `adminKey`, we should update it as well 
in the [plugins/create-jobs.sh](https://github.com/kamgastephane/docker-cronicle/blob/master/plugins/create-jobs.sh)
https://github.com/kamgastephane/docker-cronicle/blob/e7982bbf2f342cb54bb687408bc5d9ab8880f8b5/plugins/create-jobs.sh#L3-L7

#### Others
Much more can be achieved by modifying the `setup.json` file.
A good starting point can be found there:
* [Default setup.json](https://github.com/jhuckaby/Cronicle/blob/master/sample_conf/setup.json)
* [Thread on automating cronicle by the author](https://github.com/jhuckaby/Cronicle/issues/12)


## Event creation
Event can be created automatically during the initial setup.
You just need to create the proper JSON file and add it into the `jobs` folder.
This project contains two sample jobs.
* one for running a mongo backup, once a day at 4 AM
* one for running a POST http call every 5 minute to a dummy endpoint

A hack for quickly prototyping event, is to create them from the UI, then observe the traffic and capture the payload of the request made by the browser ruding the creation of the event.
Once you have the payload, you can modify it and add it to the jobs folder.

The creation of jobs is done through API using a plugin.
The script in charge of creating the jobs can be found [here](https://github.com/kamgastephane/docker-cronicle/blob/master/plugins/create-jobs.sh).
The script is launched 90s after starting the server.
We will notice the presence of the ApiKey which was created earlier in the `setup.json`


## Web UI credentials
The default credentials for the web interface are: `admin` / `admin`

# Reference
https://github.com/nicholasamorim/docker-cronicle
https://github.com/jhuckaby/Cronicle
