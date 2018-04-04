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

. /etc/PhpPlatform/platform.config

cd $STAGING_DIR

chown -R $APP_USER:$EB_APP_USER $STAGING_DIR
chown -R $APP_USER:$EB_APP_USER /var/log/apache2

# If the user is using Symfony, then fix permissions
if [ -f app/SymfonyRequirements.php ]; then
  echo 'Ensuring that Symfony2 cache and log dir are writable by webapp'

  setfacl -R -m u:$APP_USER:rwx -m u:root:rwx app/cache app/logs
  setfacl -dR -m u:$APP_USER:rwx -m u:root:rwx app/cache app/logs

  chmod -R 1755 ./app/{cache,logs}
fi
