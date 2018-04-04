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

#!/bin/bash

. $BUILDER_DIR/CONFIG

rm -rf /etc/apache2/

apt-get install -y apache2

#rsync -ar $BUILDER_DIR/platform-uploads/etc/apache2/ /etc/apache2/
#chmod 755 /etc/apache2/
#chmod 644 /etc/apache2/apache2.conf
#chown -R root.root /etc/apache2/

#chkconfig apache2 on
systemctl start apache2
systemctl enable apache2

#enable mode rewrite
a2enmod rewrite
a2enmod headers
systemctl restart apache2