#!/bin/bash


DIR=$(dirname $(readlink -f "${0}"))
cd "${DIR}"

ENV_FILE=.env

if [ -f "${ENV_FILE}" ]; then
    echo "'${ENV_FILE}' already exists. aborting."
    exit 1
fi


WP_PASSWORD=$(openssl rand -base64 15)


echo "WORDPRESS_DB_HOST=sql" > "${ENV_FILE}"
echo "WORDPRESS_DB_USER=wp" >> "${ENV_FILE}"
echo "WORDPRESS_DB_PASSWORD=${WP_PASSWORD}" >> "${ENV_FILE}"
echo "WORDPRESS_DB_NAME=wp" >> "${ENV_FILE}"

