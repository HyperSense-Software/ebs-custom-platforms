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

rm -rfv /var/www/html
ln -sfv /var/app/current /var/www/html

#EB_APP_DEPLOY_DIR=$(/opt/elasticbeanstalk/bin/get-config  container -k app_deploy_dir)
#PHP_DOCUMENT_ROOT=$(/opt/elasticbeanstalk/bin/get-config  optionsettings -n aws:elasticbeanstalk:container:php:phpini -o document_root)

#mkdir -p $EB_APP_DEPLOY_DIR/$PHP_DOCUMENT_ROOT

# Use environment variables with Apache. Apache will source /etc/sysconfig/httpd
# before starting, and the variables exported in this file can be used directly
# in Apache configuration files. These variables will also be available to PHP
# using the $ENV[''] superglobal.
# See: http://serverfault.com/a/64663
#grep -q '/opt/elasticbeanstalk/support/envvars' /etc/sysconfig/httpd || echo '. /opt/elasticbeanstalk/support/envvars' >> /etc/sysconfig/httpd

#EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config  container -k app_user)

# Add PHP to the DirectoryIndex
sed -i 's/DirectoryIndex .*/DirectoryIndex index.php index.html/g' /etc/apache2/apache2.conf

# Set MaxKeepAliveRequests to 0 and KeepAliveTimeout to 60
sed -i 's/MaxKeepAliveRequests 100/MaxKeepAliveRequests 0/g' /etc/apache2/apache2.conf
sed -i 's/KeepAliveTimeout 5/KeepAliveTimeout 60/g' /etc/apache2/apache2.conf

# Update the httpd.conf file to enable the use of .htaccess
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Disable directory indexing
sed -i 's/Indexes FollowSymLinks/FollowSymLinks/g' /etc/apache2/apache2.conf

# Configure mpm_prefork.conf 
> /etc/apache2/mods-enabled/mpm_prefork.conf
cat >> /etc/apache2/mods-enabled/mpm_prefork.conf <<END_OF_TEXT
# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxRequestWorkers: maximum number of server processes allowed to start
# MaxConnectionsPerChild: maximum number of requests a server process serves

<IfModule mpm_prefork_module>
        ServerLimit             4000
        StartServers            50
        MinSpareServers         100
        MaxSpareServers         200
        MaxRequestWorkers       4000
        MaxConnectionsPerChild  20000
        MaxRequestsPerChild     20000
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

END_OF_TEXT

# Configure Apache for AWS if it has not been already

if grep -q 'AWS Settings' /etc/apache2/apache2.conf; then
  echo 'Apache is already configured'
else
    cat >> /etc/apache2/apache2.conf <<END_OF_TEXT

#### AWS Settings ####

# Disable ETag headers
FileETag none

# Hide Apache and PHP info
Header unset Server
Header unset X-Powered-By

# Don't expose server versions
ServerSignature Off
ServerTokens Prod

# Enable server-status for internal IP
<Location /server-status>
   SetHandler server-status
   Require ip 127.0.0.1
</Location>

# Configure /var/www/html
<Directory "/var/www/html">
    Options FollowSymLinks
    AllowOverride All
    DirectoryIndex index.html index.php
    Require all granted
</Directory>

# Add remote IP to log
LogFormat "%h (%{X-Forwarded-For}i) %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined

#### End of AWS Settings ####

END_OF_TEXT
fi

# Add better mime-types
cp /opt/elasticbeanstalk/support/conf/httpd/add-types.conf /etc/apache2/conf-enabled/add-types.conf

# Ensure that the timeout is greater than the default ELB timeout
cp /opt/elasticbeanstalk/support/conf/httpd/mod_reqtimeout.conf /etc/apache2/conf-enabled/mod_reqtimeout.conf

# Disable client specified proxy injection
cp /opt/elasticbeanstalk/support/conf/httpd/unset_proxy_header.conf /etc/apache2/conf-enabled/unset_proxy_header.conf

# Disable unused modules. If they don't exist, then that's fine because it 
# probably means this script has already run
#mv /etc/apache2/conf-enabled/userdir.conf /etc/apache2/conf-enabled/userdir.conf.disabled 2>/dev/null || true
#mv /etc/httpd/conf.modules.d/00-lua.conf /etc/httpd/conf.modules.d/00-lua.conf.disabled 2>/dev/null || true
#mv /etc/httpd/conf.modules.d/00-dav.conf /etc/httpd/conf.modules.d/00-dav.conf.disabled 2>/dev/null || true
#mv /etc/httpd/conf.modules.d/01-cgi.conf /etc/httpd/conf.modules.d/01-cgi.conf.disabled 2>/dev/null || true
# Disable unused config files, and again, allow them to fail silently if this 
# script has already run
#mv /etc/apache2/conf-enabled/autoindex.conf /etc/apache2/conf-enabled/autoindex.conf.disable 2>/dev/null || true
#mv /etc/apache2/conf-enabled/welcome.conf /etc/apache2/conf-enabled/welcome.conf.disable 2>/dev/null || true
