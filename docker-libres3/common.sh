MULTIRUN_TEMPFILE=$(mktemp)
multirun() {
    (while read -r CMD; do
        cat <<EOF
        screen -L -t '$CMD' sh -c '$CMD; printf '\''\nCommand $CMD exited with code '\''"\$?\n"'
        split
        focus
EOF
    done) | head -n -2 >"$MULTIRUN_TEMPFILE"
}

multirun_wait() {
    rm -f screenlog.*
    cat $MULTIRUN_TEMPFILE
    screen -L -c "$MULTIRUN_TEMPFILE"
    rm -f "$MULTIRUN_TEMPFILE"
    tail screenlog.*
}
