#!/bin/bash
#
# ThingsBoard, Inc. ("COMPANY") CONFIDENTIAL
#
# Copyright © 2016-2022 ThingsBoard, Inc. All Rights Reserved.
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

for i in "$@"
do
case $i in
    --fromVersion=*)
    FROM_VERSION="${i#*=}"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

fromVersion="${FROM_VERSION// }"

set -e

source compose-utils.sh

COMPOSE_VERSION=$(composeVersion) || exit $?

DEPLOYMENT_FOLDER=$(deploymentFolder) || exit $?

MAIN_SERVICE_NAME=$(mainServiceName) || exit $?

ADDITIONAL_COMPOSE_QUEUE_ARGS=$(additionalComposeQueueArgs) || exit $?

ADDITIONAL_COMPOSE_ARGS=$(additionalComposeArgs) || exit $?

ADDITIONAL_CACHE_ARGS=$(additionalComposeCacheArgs) || exit $?

ADDITIONAL_COMPOSE_EDQS_ARGS=$(additionalComposeEdqsArgs) || exit $?

ADDITIONAL_STARTUP_SERVICES=$(additionalStartupServices) || exit $?

cd $DEPLOYMENT_FOLDER

COMPOSE_ARGS_PULL="\
      --env-file ../.env \
      -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS}
      ${ADDITIONAL_COMPOSE_EDQS_ARGS} \
      pull \
      ${MAIN_SERVICE_NAME}"

COMPOSE_ARGS_UP="\
      --env-file ../.env \
      -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS}
      ${ADDITIONAL_COMPOSE_EDQS_ARGS} \
      up -d ${ADDITIONAL_STARTUP_SERVICES}"

COMPOSE_ARGS_RUN="\
      --env-file ../.env \
      -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS}
      ${ADDITIONAL_COMPOSE_EDQS_ARGS} \
      run --no-deps --rm -e UPGRADE_TB=true -e FROM_VERSION=${fromVersion} \
      ${MAIN_SERVICE_NAME}"

case $COMPOSE_VERSION in
    V2)
        docker compose $COMPOSE_ARGS_PULL
        docker compose $COMPOSE_ARGS_UP
        docker compose $COMPOSE_ARGS_RUN
    ;;
    V1)
        docker-compose $COMPOSE_ARGS_PULL
        docker-compose $COMPOSE_ARGS_UP
        docker-compose $COMPOSE_ARGS_RUN
    ;;
    *)
        # unknown option
    ;;
esac

cd ~-
