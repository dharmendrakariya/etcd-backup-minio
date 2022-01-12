#! /bin/bash
set -e -o pipefail

DB="$1"

ENDPOINTS="$2"


echo $ENDPOINTS

mc alias set pg "$MINIO_SERVER" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api "$MINIO_API_VERSION" > /dev/null

echo "Dumping $DB to $ARCHIVE"

echo "> ETCDCTL_API=3 etcdctl --endpoints=$ENDPOINTS --cert=/certs/server.crt --cacert=/certs/ca.crt --key=/certs/server.key snapshot save ${DB}-$(date "$DATE_FORMAT")"

etcdctl --endpoints=$ENDPOINTS --cert=/certs/server.crt --cacert=/certs/ca.crt --key=/certs/server.key snapshot save ${DB}-$(date "$DATE_FORMAT")

echo " coping ${DB}-$(date "$DATE_FORMAT") to pg/${MINIO_BUCKET} "

echo "> mc cp ${DB}-$(date "$DATE_FORMAT") pg/${MINIO_BUCKET} --json "

mc cp ${DB}-$(date "$DATE_FORMAT") pg/${MINIO_BUCKET} --json  || { echo "Backup failed"; mc rm "pg/$ARCHIVE"; exit 1; }

echo "size check"
 
ls -lah ${DB}-$(date "$DATE_FORMAT")

echo "Backup complete"
