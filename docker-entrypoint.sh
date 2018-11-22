#! /usr/bin/env sh

# Where are we going to mount the remote webdav resource in our container.
DEST=${WEBDRIVE_MOUNT:-/mnt/webdrive}

# Check variables and defaults
if [ -z "${WEBDRIVE_URL}" ]; then
    echo "No URL specified!"
    exit
fi
if [ -z "${WEBDRIVE_USERNAME}" ]; then
    echo "No username specified, is this on purpose?"
fi
if [ -n "${WEBDRIVE_PASSWORD_FILE}" ]; then
    WEBDRIVE_PASSWORD=$(read ${WEBDRIVE_PASSWORD_FILE})
fi
if [ -z "${WEBDRIVE_PASSWORD}" ]; then
    echo "No password specified, is this on purpose?"
fi

# Create secrets file and forget about the password once done (this will have
# proper effects when the PASSWORD_FILE-version of the setting is used)
echo "$DEST $WEBDRIVE_USERNAME $WEBDRIVE_PASSWORD" >> /etc/davfs2/secrets
unset WEBDRIVE_PASSWORD

# Add davfs2 options out of all the environment variables starting with DAVFS2_
# at the end of the configuration file. Nothing is done to check that these are
# valid davfs2 options, use at your own risk.
if [ -n "$(env | grep "DAVFS2_")" ]; then
    echo "" >> /etc/davfs2/davfs2.conf
    echo "[$DEST]" >> /etc/davfs2/davfs2.conf
    for VAR in $(env); do 
        if [ -n "$(echo "$VAR" | grep -E '^DAVFS2_')" ]; then
            OPT_NAME=$(echo "$VAR" | sed -r "s/DAVFS2_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]')
            VAR_FULL_NAME=$(echo "$VAR" | sed -r "s/([^=]*)=.*/\1/g")
            VAL=$(eval echo \$$VAR_FULL_NAME)
            echo "$OPT_NAME $VAL" >> /etc/davfs2/davfs2.conf
        fi
    done
fi

# Create destination directory if it does not exist.
if [ ! -d $DEST ]; then
    mkdir -p $DEST
fi

# Deal with ownership
if [ $OWNER -gt 0 ]; then
    useradd webdrive -u $OWNER -N -G users
    chown webdrive $DEST
fi

# Mount and verify that something is present. davfs2 always creates a lost+found
# sub-directory, so we can use the presence of some file/dir as a marker to
# detect that mounting was a success. Execute the command on success.
mount -t davfs $WEBDRIVE_URL $DEST -o uid=$OWNER,gid=users,dir_mode=755,file_mode=755
if [ -n "$(ls -1A $DEST)" ]; then
    echo "Mounted $WEBDRIVE_URL onto $DEST"
    exec "$@"
else
    echo "Nothing found in $DEST, giving up!"
fi