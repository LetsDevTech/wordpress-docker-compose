#!/bin/bash



DEBUG=Y
echo "############ Wordpress Simple Setup Script ############"

CADDYFILE=./caddy/Caddyfile

./sql/setup-env.sh

while [ -z "${SETUP_WP}" ]; do
    read -p "Generate wordpress setup? [Y/n] " SETUP_WP

    if [ ! -z "${SETUP_WP}" ]; then
        if [ "${SETUP_WP}" == "y" ]; then
            SETUP_WP="Y"
        fi

        if [ "${SETUP_WP}" == "n" ]; then
            SETUP_WP="N"
        fi

        if [ "${SETUP_WP}" != "N" ] && [ "${SETUP_WP}" != "Y" ]; then
            unset SETUP_WP
        fi
    else
        SETUP_WP=Y
    fi
done

while [ -z "${SETUP_MAUTIC}" ]; do
    read -p "Generate mautic setup? [Y/n] " SETUP_MAUTIC

    if [ ! -z "${SETUP_MAUTIC}" ]; then
        if [ "${SETUP_MAUTIC}" == "y" ]; then
            SETUP_MAUTIC="Y"
        fi

        if [ "${SETUP_MAUTIC}" == "n" ]; then
            SETUP_MAUTIC="N"
        fi

        if [ "${SETUP_MAUTIC}" != "N" ] && [ "${SETUP_MAUTIC}" != "Y" ]; then
            unset SETUP_MAUTIC
        fi
    else
        SETUP_MAUTIC=Y
    fi
done

if [ $SETUP_WP == "Y" ]; then
    ./wp/setup-env.sh
    
    while [ -z "${DOMAIN_NAME}" ]; do
        if [ "${DEBUG}" == "Y" ]; then
            read -p "Enter the the domain name where this wordpress instance should be reached: [wp.localhost] " DOMAIN_NAME
            test -z "${DOMAIN_NAME}" && DOMAIN_NAME=wp.localhost
        else
            read -p "Enter the the domain name where this wordpress instance should be reached: " DOMAIN_NAME
        fi
    done

    while [ -z "${WWW_REDIRECT}" ]; do
        read -p "Add www to domain redirection ? [y/N]: " WWW_REDIRECT
        if [ ! -z "${WWW_REDIRECT}" ]; then
            if [ "${WWW_REDIRECT}" == "y" ]; then
                WWW_REDIRECT="Y"
            fi

            if [ "${WWW_REDIRECT}" == "n" ]; then
                WWW_REDIRECT="N"
            fi

            if [ "${WWW_REDIRECT}" != "N" ] && [ "${WWW_REDIRECT}" != "Y" ]; then
                unset WWW_REDIRECT
            fi
        else
            WWW_REDIRECT=N
        fi
    done
fi

if [ $SETUP_MAUTIC == "Y" ]; then
    ./mautic/setup-env.sh
    
    while [ -z "${MAUTIC_DOMAIN_NAME}" ]; do
        if [ "${DEBUG}" == "Y" ]; then
            read -p "Enter the the domain name where this mautic instance should be reached: [mautic.localhost] " MAUTIC_DOMAIN_NAME
            test -z "${MAUTIC_DOMAIN_NAME}" && MAUTIC_DOMAIN_NAME=mautic.localhost
        else
            read -p "Enter the the domain name where this mautic instance should be reached: " MAUTIC_DOMAIN_NAME
        fi
    done
fi

if [ $SETUP_WP == "N" ] && [ $SETUP_MAUTIC == "N" ]; then
    echo "Aborting. Nothing to do."
    exit 0
fi

TMP_FILE=(mktemp)

if [ $SETUP_WP == "Y" ]; then
    cat <<EOF >> "${TMP_FILE}"

##### Wordpress setup #####
${DOMAIN_NAME} {
    root * /var/www/html/wp
    encode gzip
    php_fastcgi wordpress:9000 {
        capture_stderr
    }
    file_server
}
EOF

    if [ "${WWW_REDIRECT}" == "Y" ]; then
        cat <<EOF >> "${TMP_FILE}"

# www to domain redirect
www.${DOMAIN_NAME} {
    redir {http.request.proto}://${DOMAIN_NAME}{uri}
}
EOF
    fi

    echo "##### Wordpress setup - END #####" >> "${TMP_FILE}"
fi

if [ $SETUP_MAUTIC == "Y" ]; then
    cat <<EOF >> "${TMP_FILE}"

##### Mautic setup #####
${MAUTIC_DOMAIN_NAME} {
    root * /var/www/html
    encode gzip
    php_fastcgi mautic:9000 {
        capture_stderr
    }
    file_server
}
##### Mautic setup - END #####
EOF
fi

DATE_TIME_STR=$(date +"%F %T")

cat <<EOF > "${CADDYFILE}"
## [${DATE_TIME_STR}]: Auto Generated Caddyfile by "configure.sh" script

EOF

cat "${TMP_FILE}" >> "${CADDYFILE}"

rm "${TMP_FILE}"

COMPOSE_FILE=docker-compose.yaml

echo '
version: "'3.8'"
services:
  reverse_proxy:
    container_name: reverse_proxy
    hostname: reverse_proxy
    image: caddy:alpine
    volumes:
      - ./caddy/config:/config
      - ./caddy/data:/data
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile' > "${COMPOSE_FILE}"

if [ "${SETUP_WP}" == "Y" ]; then
    echo '      - ./wp/data:/var/www/html/wp' >> "${COMPOSE_FILE}"
fi

if [ "${SETUP_MAUTIC}" == "Y" ]; then
    echo '      - ./mautic/data:/var/www/html' >> "${COMPOSE_FILE}"
fi

echo '    networks:
      - mkt
      - reverse_proxy
    ports:
      - 80:80
      - 443:443' >> "${COMPOSE_FILE}"

if [ "${SETUP_MAUTIC}" == "Y" ]; then
    echo '  mautic:
    container_name: mautic
    hostname: mautic
    image: mautic/mautic:v4-fpm
    env_file:
      - ./mautic/.env
    networks:
      - mkt
    volumes:
      - ./mautic/data:/var/www/html' >> "${COMPOSE_FILE}"
fi

if [ "${SETUP_WP}" == "Y" ]; then
    echo '  wordpress:
    container_name: wordpress
    hostname: wordpress
    image: wordpress:6.2-fpm
    working_dir: /var/www/html/wp
    env_file:
      - ./wp/.env
    networks:
      - mkt
    volumes:
      - ./wp/data:/var/www/html/wp' >> "${COMPOSE_FILE}"
fi

echo '  sql:
    container_name: sql
    hostname: sql
    image: mariadb:10-jammy
    env_file:
      - ./sql/.env
    networks: 
    - mkt
    volumes:
      - ./sql/data:/var/lib/mysql
networks:
  mkt: {}
  reverse_proxy: {}
' >> "${COMPOSE_FILE}"

./configure-databases.sh "${SETUP_WP}" "${SETUP_MAUTIC}"