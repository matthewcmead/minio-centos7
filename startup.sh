#!/usr/bin/env bash

/usr/local/bin/make-data-bucket.sh &
disown %1

chown -R minio:minio /data
exec /usr/local/bin/docker-entrypoint.sh "$@"
