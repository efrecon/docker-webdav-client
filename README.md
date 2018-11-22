# Dockerised WebDAV Client

This container facilitates mounting of remote WebDAV resources into a container.
Mounting is implemented using [davfs2] and the container makes it possible to set
all supported davfs [configuration] options for the share. Used with the proper
creation options, you should be able to bind-mount back the remote WebDAV onto a
host directory in a way that makes its content available to processes (and other
containers) on the host.

  [davfs2]: http://savannah.nongnu.org/projects/davfs2
  [configuration]: https://man.cx/davfs2.conf(5)

## Example

Provided the existence of a directory called `/mnt/tmp` on the host, the
following command would mount a remote WebDAV resource, ensure that
authentication details are never requested from the command-line and bind-mount
the remote resource onto the host's `/mnt/tmp` in a way that makes the remote
files accessible to processes and/or other containers running on the same host.

```Shell
docker run -it --rm \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    --security-opt "apparmor=unconfined" \
    --env "WEBDRIVE_USERNAME=<YourUserName>" \
    --env "WEBDRIVE_PASSWORD=<SuperSecretPassword" \
    --env "WEBDRIVE_URL=https://dav.box.com/dav" \
    --env "DAVFS2_ASK_AUTH=0" \
    -v /mnt/tmp:/mnt/webdrive:rshared \
    efrecon/webdav-client
```

The `--device`, `--cap-add` and `--security-opt` options and their values are to
make sure that the container will be able to make available the WebDAV resource
using FUSE. `rshared` is what ensures that bind mounting makes the files and
directories available back to the host and recursively to other containers.

## Container Options

A series of environment variables, most led by `WEBDRIVE_` can be used to
parametrise the container:

* `WEBDRIVE_URL` is the URL at which to find the WebDAV resource.
* `WEBDRIVE_USERNAME` is the user to use for accessing the resource.
* `WEBDRIVE_PASSWORD` is the password for that user.
* `WEBDRIVE_PASSWORD_FILE` points instead to a file that will contain the
  password for the user. When this is present, the password will be taken from
  the file instead of from the `WEBDRIVE_PASSWORD` variable. If that variable
  existed, it will be disregarded. This makes it easy to pass passwords using
  Docker [secrets].
* `WEBDRIVE_MOUNT` is the location within the container where to mounte the
  WebDAV resource. This defaults to `/mnt/webdrive` and is not really meant to
  be changed.
* `OWNER` is the user ID for the owner of the share inside the container.

  [secrets]: https://docs.docker.com/engine/swarm/secrets/

## davFS Options

All [configuration] options recognised by davFS can be given for that particular
share. Environment variables should be created out of the name of the
configuration option for this to work. Any existing option should be translated
to uppercase and led by the keyword `DAVFS2_` to be recognised. So to set the
davfs2 option called `ask_auth` to `0`, you would set the environment variable
`DAVFS2_ASK_AUTH` to `0`.