#!/bin/bash
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

function deploymentFolder() {
    source .env
    DEPLOYMENT_FOLDER=""
    case $TB_SETUP in
        monolith)
        DEPLOYMENT_FOLDER="monolith"
        ;;
        basic)
        DEPLOYMENT_FOLDER="basic"
        ;;
        advanced)
        DEPLOYMENT_FOLDER="advanced"
        ;;
        *)
        echo "Unknown or missing TB_SETUP value specified in the .env file: '${TB_SETUP}'. Should be either 'monolith' or 'basic' or 'advanced'." >&2
        exit 1
    esac
    echo $DEPLOYMENT_FOLDER
}

function mainServiceName() {
    source .env
    MAIN_SERVICE_NAME=""
    case $TB_SETUP in
        monolith)
        MAIN_SERVICE_NAME="tb-monolith"
        ;;
        basic)
        MAIN_SERVICE_NAME="tb-monolith"
        ;;
        advanced)
        MAIN_SERVICE_NAME="tb-core1"
        ;;
        *)
        echo "Unknown or missing TB_SETUP value specified in the .env file: '${TB_SETUP}'. Should be either 'monolith' or 'basic' or 'advanced'." >&2
        exit 1
    esac
    echo $MAIN_SERVICE_NAME
}

function additionalComposeArgs() {
    source .env
    ADDITIONAL_COMPOSE_ARGS=""
    case $DATABASE in
        postgres)
        ADDITIONAL_COMPOSE_ARGS="-f docker-compose.postgres.yml"
        ;;
        hybrid)
        ADDITIONAL_COMPOSE_ARGS="-f docker-compose.hybrid.yml"
        ;;
        *)
        echo "Unknown DATABASE value specified in the .env file: '${DATABASE}'. Should be either 'postgres' or 'hybrid'." >&2
        exit 1
    esac
    echo $ADDITIONAL_COMPOSE_ARGS
}

function additionalComposeQueueArgs() {
    source .env
    ADDITIONAL_COMPOSE_QUEUE_ARGS=""
    case $TB_QUEUE_TYPE in
        kafka)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.kafka.yml"
        ;;
        confluent)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.confluent.yml"
        ;;
        aws-sqs)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.aws-sqs.yml"
        ;;
        pubsub)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.pubsub.yml"
        ;;
        rabbitmq)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.rabbitmq.yml"
        ;;
        service-bus)
        ADDITIONAL_COMPOSE_QUEUE_ARGS="-f docker-compose.service-bus.yml"
        ;;
        *)
        echo "Unknown Queue service value specified in the .env file: '${TB_QUEUE_TYPE}'. Should be either 'kafka' or 'confluent' or 'aws-sqs' or 'pubsub' or 'rabbitmq' or 'service-bus'." >&2
        exit 1
    esac
    echo $ADDITIONAL_COMPOSE_QUEUE_ARGS
}

function additionalComposeMonitoringArgs() {
    source .env

    if [ "$MONITORING_ENABLED" = true ]
    then
      ADDITIONAL_COMPOSE_MONITORING_ARGS="-f docker-compose.prometheus-grafana.yml"
      echo $ADDITIONAL_COMPOSE_MONITORING_ARGS
    else
      echo ""
    fi
}

function additionalComposeOverrideArgs() {
    source .env

    if [ -f ./docker-compose.override.yml ]
    then
      ADDITIONAL_COMPOSE_OVERRIDE_ARGS="-f ../docker-compose.override.yml"
      echo $ADDITIONAL_COMPOSE_OVERRIDE_ARGS
    else
      echo ""
    fi
}

function additionalStartupServices() {
    source .env
    ADDITIONAL_STARTUP_SERVICES=""
    case $DATABASE in
        postgres)
        ADDITIONAL_STARTUP_SERVICES=postgres
        ;;
        hybrid)
        ADDITIONAL_STARTUP_SERVICES="postgres cassandra"
        ;;
        *)
        echo "Unknown DATABASE value specified: '${DATABASE}'. Should be either postgres or hybrid." >&2
        exit 1
    esac
    echo $ADDITIONAL_STARTUP_SERVICES
}
