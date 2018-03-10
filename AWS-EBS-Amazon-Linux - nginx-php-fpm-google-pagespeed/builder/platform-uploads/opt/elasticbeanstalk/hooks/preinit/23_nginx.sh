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

#!/usr/bin/env bash

cp -f /opt/elasticbeanstalk/support/conf/nginx/nginx.conf /etc/nginx/nginx.conf

cp -f /opt/elasticbeanstalk/support/conf/nginx/php.conf-7.1 /etc/nginx/default.d/php.conf-7.1

cp -f /opt/elasticbeanstalk/support/conf/nginx/gzip.conf /etc/nginx/conf.d/gzip.conf

cp -f /opt/elasticbeanstalk/support/conf/nginx/ngx_pagespeed.conf /etc/nginx/default.d/ngx_pagespeed.conf 

cp -f /opt/elasticbeanstalk/support/conf/nginx/ngx_pagespeed_module.conf /usr/share/nginx/modules/ngx_pagespeed_module.conf

cp -f /opt/elasticbeanstalk/support/conf/php-fpm/php-fpm.conf /etc/php-fpm-7.1.conf

cp -f /opt/elasticbeanstalk/support/conf/php-fpm/www.conf /etc/php-fpm-7.1.d/www.conf

cp -f /opt/elasticbeanstalk/support/conf/cron/healthd.nginx.conf /etc/cron.hourly/cron.logcleanup.elasticbeanstalk.healthd.nginx.conf

chmod +x /etc/cron.hourly/cron.logcleanup.elasticbeanstalk.healthd.nginx.conf