#
# ThingsBoard, Inc. ("COMPANY") CONFIDENTIAL
#
# Copyright © 2016-2019 ThingsBoard, Inc. All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains
# the property of ThingsBoard, Inc. and its suppliers,
# if any.  The intellectual and technical concepts contained
# herein are proprietary to ThingsBoard, Inc.
# and its suppliers and may be covered by U.S. and Foreign Patents,
# patents in process, and are protected by trade secret or copyright law.
#
# Dissemination of this information or reproduction of this material is strictly forbidden
# unless prior written permission is obtained from COMPANY.
#
# Access to the source code contained herein is hereby forbidden to anyone except current COMPANY employees,
# managers or contractors who have executed Confidentiality and Non-disclosure agreements
# explicitly covering such access.
#
# The copyright notice above does not evidence any actual or intended publication
# or disclosure  of  this source code, which includes
# information that is confidential and/or proprietary, and is a trade secret, of  COMPANY.
# ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
# OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT
# THE EXPRESS WRITTEN CONSENT OF COMPANY IS STRICTLY PROHIBITED,
# AND IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL TREATIES.
# THE RECEIPT OR POSSESSION OF THIS SOURCE CODE AND/OR RELATED INFORMATION
# DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS,
# OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
#

mkdir -p tb-node/log && sudo chown -R 799:799 tb-node/log

mkdir -p tb-node/data && sudo chown -R 799:799 tb-node/data

mkdir -p tb-transports/coap/log && sudo chown -R 799:799 tb-transports/coap/log

mkdir -p tb-transports/lwm2m/log && sudo chown -R 799:799 tb-transports/lwm2m/log

mkdir -p tb-transports/http/log && sudo chown -R 799:799 tb-transports/http/log

mkdir -p tb-transports/mqtt/log && sudo chown -R 799:799 tb-transports/mqtt/log

mkdir -p tb-transports/snmp/log && sudo chown -R 799:799 tb-transports/snmp/log

mkdir -p tb-vc-executor/log && sudo chown -R 799:799 tb-vc-executor/log

mkdir -p tb-node/postgres && sudo chown -R 999:999 tb-node/postgres

mkdir -p tb-node/cassandra && sudo chown -R 999:999 tb-node/cassandra

source .env
CACHE="${CACHE:-redis}"
case $CACHE in
    redis)
    mkdir -p tb-node/redis-data && sudo chown -R 1001:0 tb-node/redis-data
    ;;
    redis-cluster)
    mkdir -p tb-node/redis-cluster-data-0 && sudo chown -R 1001:0 tb-node/redis-cluster-data-0
    mkdir -p tb-node/redis-cluster-data-1 && sudo chown -R 1001:0 tb-node/redis-cluster-data-1
    mkdir -p tb-node/redis-cluster-data-2 && sudo chown -R 1001:0 tb-node/redis-cluster-data-2
    mkdir -p tb-node/redis-cluster-data-3 && sudo chown -R 1001:0 tb-node/redis-cluster-data-3
    mkdir -p tb-node/redis-cluster-data-4 && sudo chown -R 1001:0 tb-node/redis-cluster-data-4
    mkdir -p tb-node/redis-cluster-data-5 && sudo chown -R 1001:0 tb-node/redis-cluster-data-5
    ;;
    *)
    echo "Unknown CACHE value specified in the .env file: '${CACHE}'. Should be either 'redis' or 'redis-cluster'." >&2
    exit 1
esac

mkdir -p tb-integration-executor/log && sudo chown -R 799:799 tb-integration-executor/log