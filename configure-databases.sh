#!/bin/bash

SETUP_WP="${1}"
SETUP_MAUTIC="${2}"

./configure-sql-pki.sh

docker compose up -d sql

# TODO: Check for sql container ready
sleep 10
DB_ENV_FILE=./sql/.env
MAUTIC_ENV_FILE=./mautic/.env
WP_ENV_FILE=./wp/.env

DB_ROOT_PASSWORD=$(grep MARIADB_ROOT_PASSWORD "${DB_ENV_FILE}")
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD/MARIADB_ROOT_PASSWORD=/}"

if [ "${SETUP_WP}" == "Y" ]; then
    DB_PASSWORD=$(grep WORDPRESS_DB_PASSWORD "${WP_ENV_FILE}")
    DB_USER=$(grep WORDPRESS_DB_USER "${WP_ENV_FILE}")
    DB_DATABASE=$(grep WORDPRESS_DB_NAME "${WP_ENV_FILE}")

    DB_PASSWORD="${DB_PASSWORD/WORDPRESS_DB_PASSWORD=/}"
    DB_USER="${DB_USER/WORDPRESS_DB_USER=/}"
    DB_DATABASE="${DB_DATABASE/WORDPRESS_DB_NAME=/}"

    CREATE_DB_SQL="create database \`${DB_DATABASE}\`;"
    CREATE_USER_SQL="create user \`${DB_USER}\`@\`%\` identified by '${DB_PASSWORD}';"
    GRANT_SQL="grant all privileges on \`${DB_DATABASE}\`.* to \`${DB_USER}\`;";
    
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${CREATE_DB_SQL}"
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${CREATE_USER_SQL}"
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${GRANT_SQL}"
fi

if [ "${SETUP_MAUTIC}" == "Y" ]; then
    DB_PASSWORD=$(grep MAUTIC_DB_PASSWORD "${MAUTIC_ENV_FILE}")
    DB_USER=$(grep MAUTIC_DB_USER "${MAUTIC_ENV_FILE}")
    DB_DATABASE=$(grep MAUTIC_DB_NAME "${MAUTIC_ENV_FILE}")

    DB_PASSWORD="${DB_PASSWORD/MAUTIC_DB_PASSWORD=/}"
    DB_USER="${DB_USER/MAUTIC_DB_USER=/}"
    DB_DATABASE="${DB_DATABASE/MAUTIC_DB_NAME=/}"

    CREATE_DB_SQL="create database \`${DB_DATABASE}\`;"
    CREATE_USER_SQL="create user \`${DB_USER}\`@\`%\` identified by '${DB_PASSWORD}';"
    GRANT_SQL="grant all privileges on \`${DB_DATABASE}\`.* to \`${DB_USER}\`;";
    
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${CREATE_DB_SQL}"
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${CREATE_USER_SQL}"
    docker exec -it sql mysql --password="${DB_ROOT_PASSWORD}" -e "${GRANT_SQL}"
fi

docker compose up -d