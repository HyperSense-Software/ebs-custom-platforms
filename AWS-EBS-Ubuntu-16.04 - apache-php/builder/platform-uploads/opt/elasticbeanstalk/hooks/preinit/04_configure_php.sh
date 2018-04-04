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

set -xe

# Update PHP and apache configurations to use environment variables
# Updates php.ini and the DocumentRoot of apache
#/opt/elasticbeanstalk/support/php_apache_env

[ "$EB_FIRST_RUN" != "true" ] && exit 0

echo "First run. Configuring PHP."

# Calculates the most appropriate APC shm size based on the instance type
function calculate_shm_size()
{
  case `curl -s http://169.254.169.254/latest/meta-data/instance-type` in
    t1.micro)
      shm_size='64M'
      ;;
    m1.small)
      shm_size='128M'
      ;;
    c1.medium)
      shm_size='128M'
      ;;
    *)
      shm_size='256M'
      ;;
  esac
}

# Add recommended settings to php.ini if they are not already set
if grep -q 'AWS Settings' /etc/apache2/apache2.conf; then
  echo 'PHP is already configured'
else
    cat >> /etc/php.ini <<END_OF_TEXT

; AWS Settings
expose_php = Off
html_errors = Off
variables_order = "EGPCS"
session.save_path = "/tmp"
default_socket_timeout = 90
post_max_size = 32M
short_open_tag = 1
date.timezone = UTC
; End of AWS Settings

END_OF_TEXT
fi

# Update apc.ini on preinit
calculate_shm_size
if [ -e /etc/php.d/apc.ini ]
then
    sed -i "s/apc.shm_size=.*/apc.shm_size=${shm_size}/g" /etc/php.d/apc.ini
    sed -i "s/apc.num_files_hint=.*/apc.num_files_hint=10000/g" /etc/php.d/apc.ini
    sed -i "s/apc.user_entries_hint=.*/apc.user_entries_hint=10000/g" /etc/php.d/apc.ini
    sed -i "s/apc.max_file_size=.*/apc.max_file_size=5M/g" /etc/php.d/apc.ini
fi

# Copy the PHPUnit Phar file to the path
cp /opt/elasticbeanstalk/support/phpunit.phar /usr/bin/phpunit.phar || true
chmod +x /usr/bin/phpunit.phar

# Comment out any PHP configurations introduced to httpd php.conf

#PHP_VERSION=$(/opt/elasticbeanstalk/bin/get-config container -k php_version)
#php_conf_paths="/etc/httpd/conf.d/php.conf"
#case $PHP_VERSION in
#  7.0)
#	php_conf_paths="$php_conf_paths /etc/httpd/conf.d/php-conf.7.0"
#    ;;
#  5.6)
#	php_conf_paths="$php_conf_paths /etc/httpd/conf.d/php-conf.5.6"
#    ;;
#  5.5)
#	php_conf_paths="$php_conf_paths /etc/httpd/conf.d/php-conf.5.5"
#    ;;
#  5.4)
#    ;;
#  *)
#  echo ERROR: PHP version $PHP_VERSION is not supported.
#  exit 1
#esac
#
#for php_conf_path in $php_conf_paths
#do
#  sed -i -r 's/^([[:space:]]*)php_value/\1# php_value/' $php_conf_path
#done