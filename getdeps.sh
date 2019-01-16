#!/usr/bin/env bash

export MINIO_DOWNLOAD_URL=https://dl.minio.io/server/minio/release/linux-amd64/archive/minio.RELEASE.2019-01-10T00-21-20Z
export MINIO_DOWNLOAD_SHA=f53629625c8b165c754ce115d1a61d57d7a1e230c7dabd7ac7f207e1da50b05d
export GOSU_VERSION=1.10
export MC_DOWNLOAD_URL=https://dl.minio.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2019-01-10T00-38-22Z
export MC_DOWNLOAD_SHA=28dfc89f5dae0676df79219653fe64fba19b3e57da196cd5ac5ae309fa208fd5
export TINI_VERSION=v0.18.0
export TINI_DOWNLOAD_URL=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini
export TINI_DOWNLOAD_SHA=12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855


export GNUPGHOME="$(mktemp -d)"

yum install -y gnupg wget

cd /project/software_dist && wget -O minio "$MINIO_DOWNLOAD_URL"
echo "$MINIO_DOWNLOAD_SHA *minio" | sha256sum -c - || MINIO_EXIT=1
if [ X$MINIO_EXIT == X1 ]; then
  echo "minio sha256sum failed"
  rm -rf minio
  exit 1
fi
cd /project/software_dist && wget -O mc "$MC_DOWNLOAD_URL"
echo "$MC_DOWNLOAD_SHA *mc" | sha256sum -c - || MC_EXIT=1
if [ X$MC_EXIT == X1 ]; then
  echo "mc sha256sum failed"
  rm -rf mc
  exit 1
fi
cd /project/software_dist && wget -O tini "$TINI_DOWNLOAD_URL"
echo "$TINI_DOWNLOAD_SHA *tini" | sha256sum -c - || TINI_EXIT=1
if [ X$TINI_EXIT == X1 ]; then
  echo "tini sha256sum failed"
  rm -rf tini
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
sed -i.bak "s/^exec /exec gosu minio /" docker-entrypoint.sh
