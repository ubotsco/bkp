#!/bin/bash

set -e

function fatal {
  echo "Error: $1" 1>&2
  exit 1
}

PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"

[ -z "${PGHOST}" ] && fatal "PGHOST is required"
[ -z "${PGPORT}" ] && fatal "PGPORT is required"
[ -z "${PGUSER}" ] && fatal "PGUSER is required"
[ -z "${PGPASSWORD}" ] && fatal "PGPASSWORD is required"
[ -z "${PGDATABASE}" ] && fatal "PGDATABASE is required"

[ -z "${AWS_ACCESS_KEY_ID}" ] && fatal "AWS_ACCESS_KEY_ID is required"
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && fatal "AWS_SECRET_ACCESS_KEY is required"
[ -z "${S3_BUCKET}" ] && fatal "S3_BUCKET is required"


export PGHOST
export PGPORT
export PGUSER
export PGPASSWORD
export PGDATABASE

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export S3_BUCKET

cmd="$1"

case "${cmd}" in
  backup)
    time=$(date '+%Y-%m-%d_%H%M%S')
    dir=$(date '+%Y/%m')
    path="s3://${S3_BUCKET}/${dir}/${PGDATABASE}_${time}.sql.tgz"

    echo "--> Dumping postgres://${PGUSER}@${PGHOST}:${PGPORT}/${PGDATABASE} --> ${path}"
    pg_dump --no-password | gzip | aws s3 cp - ${path}
    aws s3 ls --human-readable ${path}
    ;;

  list)
    path="s3://${S3_BUCKET}/"
    aws s3 ls --human-readable --recursive ${path}
    ;;

  restore)
    file="$2"
    [ -z "${file}" ] && fatal "Usage: $0 restore FILE"


    path="s3://${S3_BUCKET}/${file}"
    echo "--> Downloading ${path}"
    aws s3 cp "${path}" - | gzip -d > "dump.sql"


    echo "--> Recreating database ${PGDATABASE}"
    dropdb --force --if-exists "${PGDATABASE}"
		createdb -O "${PGUSER}" "${PGDATABASE}"

    echo "--> Restoring database ${PGDATABASE}"
    psql -f "dump.sql"
    ;;

  *)
    echo "Usage: $0 COMMAND"
    echo "  $0 backup"
    echo "  $0 list"
    echo "  $0 restore FILE"
    exit 1
    ;;
esac
