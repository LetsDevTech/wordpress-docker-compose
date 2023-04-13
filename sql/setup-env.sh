#!/bin/bash


DIR=$(dirname $(readlink -f "${0}"))
cd "${DIR}"

ENV_FILE=.env

if [ -f "${ENV_FILE}" ]; then
    echo "'${ENV_FILE}' already exists. aborting."
    exit 1
fi

ROOT_PASSWORD=$(openssl rand -base64 15)


echo "MARIADB_ROOT_PASSWORD=${ROOT_PASSWORD}" > "${ENV_FILE}"
