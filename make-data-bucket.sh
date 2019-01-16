#!/usr/bin/env bash

RC=1

if [ ! -d /home/minio ]; then
  mkdir /home/minio
  chown minio:minio /home/minio
fi

while [ "X0" != "X$RC" ]; do
  gosu minio /usr/local/bin/mc mb data
  RC=$?
  sleep 2
done
