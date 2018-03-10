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

/opt/elasticbeanstalk/bin/get-config environment | python -c 'import json,sys;obj=json.load(sys.stdin);open("/etc/nginx/fastcgi_params_env", "wb").write("\n".join(["fastcgi_param %s %s;" % (key, obj[key]) for key in obj]));'
