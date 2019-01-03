#!/usr/bin/env bash

export MINIO_DOWNLOAD_URL=https://dl.minio.io/server/minio/release/linux-amd64/minio.RELEASE.2018-12-27T18-33-08Z
export MINIO_DOWNLOAD_SHA=f81db53e978c583ef0183cb9ae78dc3cb9daa8f93c1d0480934bf72b2372ceaa
export GOSU_VERSION=1.10

export GNUPGHOME="$(mktemp -d)"

yum install -y gnupg wget

cd /project/software_dist && wget -O minio "$MINIO_DOWNLOAD_URL"
echo "$MINIO_DOWNLOAD_SHA *minio" | sha256sum -c - || MINIO_EXIT=1
if [ X$MINIO_EXIT == X1 ]; then
  echo "minio sha256sum failed"
  rm -rf minio
  exit 1
fi

wget -O gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"
wget -O gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify gosu.asc gosu || GOSU_EXIT=1
if [ X$GOSU_EXIT == X1 ]; then
  echo "gosu gnupg signature verify failed"
  rm -f gosu*
  exit 1
fi

wget -O healthcheck.sh https://raw.githubusercontent.com/minio/minio/master/dockerscripts/healthcheck.sh
wget -O docker-entrypoint.sh https://raw.githubusercontent.com/minio/minio/master/dockerscripts/docker-entrypoint.sh
