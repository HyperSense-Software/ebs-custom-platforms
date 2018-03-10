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

. $BUILDER_DIR/CONFIG

yum install php71 \
            php71-common \
            php71-recode \
            php71-tidy \
            php71-xmlrpc \
            php71-pspell \
            php71-sqlite3 \
            php71-memcache \
            php71-mbstring \
            php71-imap \
            php71-intl \
            php71-gd \
            php71-imagick \
            php71-apcu \
            php71-curl \
            php71-dom \
            php71-mcrypt \
            php71-mysql \
            php71-bcmath \
            php71-cli \
            php71-common \
            php71-devel \
            php71-mysqlnd \
            php71-pecl-apcu \
            php71-pecl-imagick \
            php71-pecl-memcache \
            php71-pecl-memcached \
            php71-pecl-oauth \
            php71-pecl-ssh2 \
            php71-soap \
            php71-xml \
            php71-xmlrpc \
            php71-pecl-uuid \
            php71-opcache \
            -y