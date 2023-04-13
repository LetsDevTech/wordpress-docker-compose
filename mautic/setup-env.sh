#!/bin/bash


DIR=$(dirname $(readlink -f "${0}"))
cd "${DIR}"

ENV_FILE=.env
DB_ENV_FILE=../sql/.env

if [ -f "${ENV_FILE}" ]; then
    echo "'${ENV_FILE}' already exists. aborting."
    exit 1
fi

if [ ! -f "${DB_ENV_FILE}" ]; then
    echo "'${DB_ENV_FILE}' not found. aborting"
    exit 1
fi

# WP_PASSWORD=$(grep MARIADB_PASSWORD "${DB_ENV_FILE}")
MAUTIC_PASSWORD=$(openssl rand -base64 15)

echo "MAUTIC_DB_HOST=sql" > "${ENV_FILE}"
echo "MAUTIC_DB_USER=mautic" >> "${ENV_FILE}"
# echo "MAUTIC_DB_PASSWORD=${WP_PASSWORD/MARIADB_PASSWORD=/}" >> "${ENV_FILE}"
echo "MAUTIC_DB_PASSWORD=${MAUTIC_PASSWORD}" >> "${ENV_FILE}"
echo "MAUTIC_DB_NAME=mautic" >> "${ENV_FILE}"
echo "MAUTIC_RUN_CRON_JOBS=false" >> "${ENV_FILE}"

