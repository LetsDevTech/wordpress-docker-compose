#!/bin/bash


DIR=$(dirname $(readlink -f "${0}"))
cd "${DIR}"

ENV_FILE=.env

if [ -f "${ENV_FILE}" ]; then
    echo "'${ENV_FILE}' already exists. aborting."
    exit 1
fi

ROOT_PASSWORD=$(openssl rand -base64 15)
WP_PASSWORD=$(openssl rand -base64 15)

echo "MARIADB_ROOT_PASSWORD=${ROOT_PASSWORD}" > "${ENV_FILE}"
echo "MARIADB_DATABASE=wp" >> "${ENV_FILE}"
echo "MARIADB_USER=wp" >> "${ENV_FILE}"
echo "MARIADB_PASSWORD=${WP_PASSWORD}" >> "${ENV_FILE}"

