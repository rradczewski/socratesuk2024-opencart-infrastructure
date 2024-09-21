#!/usr/bin/env bash

set -euxo pipefail

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

OPENCART_DOWNLOAD_URL="https://github.com/opencart/opencart/releases/download/3.0.4.0/opencart-3.0.4.0.zip"

if docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

clean() {
    $DOCKER_COMPOSE down --remove-orphans --volumes || true
    sudo rm -Rf "${CURRENT_DIR}/workspace/html/shop" || true
    mkdir -p "${CURRENT_DIR}/workspace/html" || true
    rm -Rf "${CURRENT_DIR}/output" || true
    mkdir -p "${CURRENT_DIR}/output" || true
}

unzip_opencart_src() {
    TEMP_DIR=$(mktemp -d)
    curl -Ls "${OPENCART_DOWNLOAD_URL}" -o "${TEMP_DIR}/opencart.zip"
    unzip "${TEMP_DIR}/opencart.zip" -d "${TEMP_DIR}"
    mv "${TEMP_DIR}/upload/" "${CURRENT_DIR}/workspace/html/shop"
}

start_containers() {
    $DOCKER_COMPOSE up --build --detach --wait
}

run_opencart_cli_installer() {
    $DOCKER_COMPOSE exec web php /var/www/html/shop/install/cli_install.php install \
        --db_hostname database \
        --db_username opencart \
        --db_password opencart \
        --db_database opencart \
        --db_driver mysqli \
        --db_port 3306 \
        --username admin \
        --password admin \
        --email youremail@example.com \
        --http_server http://localhost:8080/shop/
}

zip_opencart() {
    zip -r "${CURRENT_DIR}/output/opencart.zip" "${CURRENT_DIR}/workspace/html/shop"
}

dump_database() {
    $DOCKER_COMPOSE exec database sh -c 'mysqldump -u root -popencart opencart' >"${CURRENT_DIR}/output/opencart.sql"
}

run() {
    clean
    unzip_opencart_src
    start_containers
    
    run_opencart_cli_installer

    #install_sebs_extensions
    #apply_sebs_patches

    zip_opencart
    dump_database
    #push_to_prod
}

run
