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

if [ -f /etc/logrotate.d/nginx ]
then
    /opt/elasticbeanstalk/bin/log-conf -n'nginx' -l'/var/log/nginx/*' -f /opt/elasticbeanstalk/support/conf/nginx.logrotate.conf
    rm -f /etc/logrotate.d/nginx
fi

if [ -f /etc/logrotate.d/php-fpm-7.1 ]
then
    /opt/elasticbeanstalk/bin/log-conf -n'php-fpm' -l'/var/log/php-fpm/7.1/*log' -f /opt/elasticbeanstalk/support/conf/php-fpm.logrotate.conf
    rm -f /etc/logrotate.d/php-fpm-7.1
fi

if [ -d /etc/healthd -a ! -d /var/log/nginx/healthd ]
then
    mkdir -p /var/log/nginx/healthd
    chown -R nginx:nginx /var/log/nginx/healthd
fi
