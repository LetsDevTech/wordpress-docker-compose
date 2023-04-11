#!/bin/bash

echo "############ Wordpress Simple Setup Script ############"

CADDYFILE=./caddy/Caddyfile

while [ -z "${SETUP_WP}" ]; do
    read -p "Generate wordpress setup? [Y/n]" SETUP_WP

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
    read -p "Generate mautic setup? [Y/n]" SETUP_MAUTIC

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
    while [ -z "${DOMAIN_NAME}" ]; do
        read -p "Enter the the domain name where this wordpress instance should be reached: " DOMAIN_NAME
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
    while [ -z "${MAUTIC_DOMAIN_NAME}" ]; do
        read -p "Enter the the domain name where this mautic instance should be reached: " MAUTIC_DOMAIN_NAME
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

