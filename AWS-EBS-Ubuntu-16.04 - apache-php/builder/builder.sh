#Copyright 2003-2018 HyperSense Software SRL
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

#!/bin/bash -xe

BUILDER_DIR="/tmp/builder/"

. $BUILDER_DIR/CONFIG

wait_for_cloudinit() {
    echo "Waiting for cloud init to finish bootstrapping.."
    until [ -f /var/lib/cloud/instance/boot-finished ]; do
        echo "Still bootstrapping.. sleeping. "
        sleep 3;
    done
}

run_command () {
    echo "Running script [$1]"
    chmod +x $1
    (cd $BUILDER_DIR/setup-scripts; BUILDER_DIR=$BUILDER_DIR $1 )
    if [ $? -ne "0" ]; then
        echo "Exiting. Failed to execute [$1]"
        exit 1
    fi
}

install_jq() {
    ##### INSTALL JQ TO HELP IN OUR HOOKS LATER ON #####
    echo "Installing jq"
    cd /tmp
    wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod +x jq-linux64
    mv jq-linux64 jq
    mv jq /usr/local/bin/
}

setup_beanstalk_base() {
    echo "Creating base directories for platform."
    mkdir -p $BEANSTALK_DIR/deploy/appsource/
    mkdir -p /var/app/staging
    mkdir -p /var/app/current
    apt-get -y install unzip
}

sync_platform_uploads() {
    ##### COPY THE everything in platform-uploads to / ####
    echo "Setting up platform hooks"
    rsync -ar $BUILDER_DIR/platform-uploads/ /
}

prepare_platform_base() {
    install_jq
    setup_beanstalk_base
    sync_platform_uploads
}

run_setup_scripts() {
    for entry in $( ls $BUILDER_DIR/setup-scripts/*.sh | sort ) ; do
        run_command $entry
    done
}

cleanup() {
    echo "Done all customization of packer instance. Cleaning up"
    rm -rf $BUILDER_DIR
}

set_permissions() {
    echo "Setting permissions in /opt/elasticbeanstalk"
    find /opt/elasticbeanstalk -type d -exec chmod 755 {} \; -print
    chown -R root:root /opt/elasticbeanstalk/
    echo "Setting permissions for shell scripts"
    find /opt/elasticbeanstalk/ -name "*.sh" -exec chmod 755 {} \; -print
    echo "setting permissions done."
}

echo "Running packer builder script"

wait_for_cloudinit
prepare_platform_base
run_setup_scripts
set_permissions
cleanup

