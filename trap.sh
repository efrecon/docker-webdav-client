exit_script() {
    SIGNAL=$1
    echo "Caught $SIGNAL! Unmounting ${DEST}..."
    umount -l ${DEST}
    dav2fs=$(ps -o pid= -o comm= | grep mount.davfs | sed -E 's/\s*(\d+)\s+.*/\1/g')
    if [ -n "$dav2fs" ]; then
        echo "Forwarding $SIGNAL to $dav2fs"
        while $(kill -$SIGNAL $dav2fs 2> /dev/null); do
            sleep 1
        done
    fi
    trap - $SIGNAL # clear the trap
    exit $?
}

trap "exit_script INT" INT
trap "exit_script TERM" TERM
