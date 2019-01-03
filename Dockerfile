FROM centos:7

ENV LANG=en_US.utf8 LC_ALL=en_US.utf8

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r minio && useradd -r -g minio minio

RUN \
    sed -i "s/override_install_langs=en_US.UTF-8/override_install_langs=en_US.utf8/g" /etc/yum.conf \
&&  yum install -y glibc-common \
&&  yum install -y \
      wget \
      ca-certificates \
      bzip2 \
      curl \
      grep \
      sed \
      which \
&& \
   yum clean all

COPY software_dist/gosu /usr/local/bin
COPY software_dist/minio /usr/local/bin
COPY software_dist/docker-entrypoint.sh /usr/local/bin
COPY software_dist/healthcheck.sh /usr/local/bin

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh \
              /usr/local/bin/healthcheck.sh \
              /usr/local/bin/gosu \
              /usr/local/bin/minio

RUN gosu nobody true

RUN mkdir /data && chown minio:minio /data
VOLUME /data
WORKDIR /data

ENV PATH=/usr/local/bin:${PATH}


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 9000
CMD ["minio"]
