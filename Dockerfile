FROM alpine:3.19.1

# Metadata
LABEL MAINTAINER=efrecon+github@gmail.com
LABEL org.opencontainers.image.title="efrecon/webdav-client"
LABEL org.opencontainers.image.description="Mount WebDAV shares from within a container and expose them to host/containers"
LABEL org.opencontainers.image.authors="Emmanuel Frécon <efrecon+github@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/efrecon/docker-webdav-client"
LABEL org.opencontainers.image.documentation="https://github.com/efrecon/docker-webdav-client/README.md"
LABEL org.opencontainers.image.source="https://github.com/efrecon/docker-webdav-client/Dockerfile"

# Specify URL, username and password to communicate with the remote webdav
# resource. When using _FILE, the password will be read from that file itself,
# which helps passing further passwords using Docker secrets.
ENV WEBDRIVE_URL=
ENV WEBDRIVE_USERNAME=
ENV WEBDRIVE_PASSWORD=
ENV WEBDRIVE_PASSWORD_FILE=

# User ID of share owner
ENV OWNER=0

# Location of directory where to mount the drive into the container.
ENV WEBDRIVE_MOUNT=/mnt/webdrive

# In addition, all variables that start with DAVFS2_ will be converted into
# davfs2 compatible options for that share, once the leading DAVFS2_ have been
# removed and once converted to lower case. So, for example, specifying
# DAVFS2_ASK_AUTH=0 will set the davfs2 configuration option ask_auth to 0 for
# that share. See the manual for the list of available options.

RUN apk --no-cache add ca-certificates davfs2 tini

COPY *.sh /usr/local/bin/

# Following should match the WEBDRIVE_MOUNT environment variable.
VOLUME [ "/mnt/webdrive" ]

# The default is to perform all system-level mounting as part of the entrypoint
# to then have a command that will keep listing the files under the main share.
# Listing the files will keep the share active and avoid that the remote server
# closes the connection.
ENTRYPOINT [ "tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "ls.sh" ]
