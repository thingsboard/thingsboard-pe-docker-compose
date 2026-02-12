#!/bin/bash
#
# ThingsBoard, Inc. ("COMPANY") CONFIDENTIAL
#
# Copyright © 2016-2026 ThingsBoard, Inc. All Rights Reserved.
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

source .env
if [ "$TRENDZ_ENABLED" != true ]
then
    echo "Cannot install Trendz while Trendz is disabled!"
    exit 1
fi

set -e
source compose-utils.sh

COMPOSE_VERSION=$(composeVersion) || exit $?

DEPLOYMENT_FOLDER=$(deploymentFolder) || exit $?

TRENDZ_SERVICE_NAME=$(trendzServiceName) || exit $?

TRENDZ_DATABASE_INIT_SERVICE_NAME=$(trendzDatabaseInitServiceName) || exit $?

ADDITIONAL_COMPOSE_QUEUE_ARGS=$(additionalComposeQueueArgs) || exit $?

ADDITIONAL_COMPOSE_ARGS=$(additionalComposeArgs) || exit $?

ADDITIONAL_CACHE_ARGS=$(additionalComposeCacheArgs) || exit $?

ADDITIONAL_COMPOSE_EDQS_ARGS=$(additionalComposeEdqsArgs) || exit $?

ADDITIONAL_COMPOSE_TRENDZ_ARGS=$(additionalComposeTrendzArgs) || exit $?

ADDITIONAL_COMPOSE_TRENDZ_DATABASE_INIT_ARGS=$(additionalComposeTrendzDatabaseInitArgs) || exit $?

ADDITIONAL_STARTUP_SERVICES=$(additionalStartupServices) || exit $?

cd $DEPLOYMENT_FOLDER

if [ ! -z "${ADDITIONAL_STARTUP_SERVICES// }" ]; then

    COMPOSE_ARGS="\
          --env-file ../.env \
          -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS} ${ADDITIONAL_COMPOSE_TRENDZ_ARGS} ${ADDITIONAL_COMPOSE_EDQS_ARGS} \
          up -d ${ADDITIONAL_STARTUP_SERVICES}"

    case $COMPOSE_VERSION in
        V2)
            docker compose $COMPOSE_ARGS
        ;;
        V1)
            docker-compose $COMPOSE_ARGS
        ;;
        *)
            # unknown option
        ;;
    esac
fi

COMPOSE_ARGS="\
      --env-file ../.env \
      -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS} ${ADDITIONAL_COMPOSE_TRENDZ_ARGS} ${ADDITIONAL_COMPOSE_EDQS_ARGS} ${ADDITIONAL_COMPOSE_TRENDZ_DATABASE_INIT_ARGS} \
      run --no-deps --rm ${TRENDZ_DATABASE_INIT_SERVICE_NAME}"

case $COMPOSE_VERSION in
    V2)
        docker compose $COMPOSE_ARGS
    ;;
    V1)
        docker-compose $COMPOSE_ARGS
    ;;
    *)
        # unknown option
    ;;
esac

COMPOSE_ARGS="\
      --env-file ../.env \
      -f docker-compose.yml ${ADDITIONAL_CACHE_ARGS} ${ADDITIONAL_COMPOSE_ARGS} ${ADDITIONAL_COMPOSE_QUEUE_ARGS} ${ADDITIONAL_COMPOSE_TRENDZ_ARGS} ${ADDITIONAL_COMPOSE_EDQS_ARGS} \
      run --no-deps --rm -e INSTALL_TRENDZ=true ${TRENDZ_SERVICE_NAME}"

case $COMPOSE_VERSION in
    V2)
        docker compose $COMPOSE_ARGS
    ;;
    V1)
        docker-compose $COMPOSE_ARGS
    ;;
    *)
        # unknown option
    ;;
esac

cd ~-
