#!/bin/bash


DIR=$(dirname $(readlink -f "${0}"))
cd "${DIR}"

ENV_FILE=.env

if [ -f "${ENV_FILE}" ]; then
    echo "'${ENV_FILE}' already exists. aborting."
    exit 1
fi

MAUTIC_PASSWORD=$(openssl rand -base64 15)

echo "MAUTIC_DB_HOST=sql" > "${ENV_FILE}"
echo "MAUTIC_DB_USER=mautic" >> "${ENV_FILE}"
echo "MAUTIC_DB_PASSWORD=${MAUTIC_PASSWORD}" >> "${ENV_FILE}"
echo "MAUTIC_DB_NAME=mautic" >> "${ENV_FILE}"
echo "MAUTIC_RUN_CRON_JOBS=false" >> "${ENV_FILE}"

