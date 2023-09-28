#!/bin/bash

# global config
MAGENTO_FOLDER="magento"
MODULE_FOLDER="src/"

# check if magento directory is empty
if [ -n "$(ls ${MODULE_FOLDER})" ]; then
    echo "${MODULE_FOLDER} directory is not empty. Skipping execution of install-magento.sh."
    exit 0
fi

# download magento
composer create-project \
    --repository-url=https://mirror.mage-os.org/ \
    magento/project-community-edition:2.4.6-p2 \
    magento-temp

# copy everything from magento-temp into magento folder
cp -r magento-temp/* ${MAGENTO_FOLDER}

# remove magento-temp
rm -rf magento-temp

# change to magento directory
cd ${MAGENTO_FOLDER} || exit 1

# install magento
bin/magento setup:install \
    --admin-email=admin@mage2-forge.ddev.site \
    --admin-firstname=Mage2 \
    --admin-lastname=Forge \
    --admin-password=admin123 \
    --admin-user=admin \
    --backend-frontname=admin \
    --db-host=db \
    --db-name=db \
    --db-password=db \
    --db-user=db \
    --search-engine=opensearch \
    --opensearch-host=opensearch \
    --opensearch-port=9200

# set config
bin/magento config:set general/locale/code en_US
bin/magento config:set web/unsecure/base_url https://mage2-forge.ddev.site/

# add repository
composer config repositories.mage2-forge vcs https://github.com/dermatz/mage2-forge.git

# require module
composer require dermatz/mage2-forge:dev-feature/add-hello-forge --prefer-source

# enable module
bin/magento setup:upgrade
