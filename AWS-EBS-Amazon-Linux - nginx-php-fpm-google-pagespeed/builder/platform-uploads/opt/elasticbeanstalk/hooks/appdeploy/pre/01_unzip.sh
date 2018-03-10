#!/usr/bin/env bash
#==============================================================================
# Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#       https://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#==============================================================================

. /etc/NginxPlatform/platform.config

if /opt/elasticbeanstalk/bin/download-source-bundle; then
	rm -rf $STAGING_DIR
	mkdir -p $STAGING_DIR
	unzip -o -d $STAGING_DIR /opt/elasticbeanstalk/deploy/appsource/source_bundle
	rm -rf $STAGING_DIR/.ebextensions
else
	echo "No application version available."
fi