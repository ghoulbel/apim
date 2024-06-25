# ------------------------------------------------------------------------
#
# Copyright 2021 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
#
# ------------------------------------------------------------------------

ARG APIM_VERSION=4.2.0.69
#FROM docker.wso2.com/wso2am:$APIM_VERSION
FROM docker.wso2.com/wso2am:$APIM_VERSION

# Add MySQL JDBC connector to server home as a third party library
ARG MYSQL_CONNECTOR_VERSION=8.3.0
ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar /home/wso2carbon/wso2-artifact-volume/repository/components/lib/
