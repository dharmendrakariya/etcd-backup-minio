# Fetch the mc command line client
FROM alpine:3.15.0 AS mc
RUN apk update && apk add ca-certificates wget && update-ca-certificates
RUN wget -O /tmp/mc https://dl.minio.io/client/mc/release/linux-amd64/mc
RUN chmod +x /tmp/mc

FROM k8s.gcr.io/etcd:3.5.1-0 AS build

# Then build our backup image
FROM ubuntu

COPY --from=mc /tmp/mc /usr/bin/mc

COPY --from=build /usr/local/bin/etcd /usr/local/bin/etcd

COPY --from=build /usr/local/bin/etcdctl /usr/local/bin/etcdctl

RUN mkdir -p /var/etcd/
RUN mkdir -p /var/lib/etcd/
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

EXPOSE 2379 2380


ENV MINIO_SERVER=""
ENV MINIO_BUCKET="backups"
ENV MINIO_ACCESS_KEY=""
ENV MINIO_SECRET_KEY=""
ENV MINIO_API_VERSION="S3v4"


ENV DATE_FORMAT="+%d-%m-%Y"

ADD entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT [ "bash", "/app/entrypoint.sh" ]
