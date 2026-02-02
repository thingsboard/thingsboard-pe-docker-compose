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
        *)
        echo "Unknown Queue service TB_QUEUE_TYPE value specified in the .env file: '${TB_QUEUE_TYPE}'. Should be either 'kafka' or 'confluent'." >&2
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

function additionalComposeCacheArgs() {
    source .env
    CACHE_COMPOSE_ARGS=""
    CACHE="${CACHE:-valkey}"
    case $CACHE in
        valkey)
        CACHE_COMPOSE_ARGS="-f docker-compose.valkey.yml"
        ;;
        valkey-cluster)
        CACHE_COMPOSE_ARGS="-f docker-compose.valkey-cluster.yml"
        ;;
        valkey-sentinel)
        CACHE_COMPOSE_ARGS="-f docker-compose.valkey-sentinel.yml"
        ;;
        *)
        echo "Unknown CACHE value specified in the .env file: '${CACHE}'. Should be either 'valkey' or 'valkey-cluster' or 'valkey-sentinel'." >&2
        exit 1
    esac
    echo $CACHE_COMPOSE_ARGS
}

function additionalComposeEdqsArgs() {
    source .env

    if [ "$EDQS_ENABLED" = true ]
    then
      ADDITIONAL_COMPOSE_EDQS_ARGS="-f docker-compose.edqs.yml"
      echo $ADDITIONAL_COMPOSE_EDQS_ARGS
    else
      echo ""
    fi
}

function additionalStartupServices() {
    source .env
    ADDITIONAL_STARTUP_SERVICES=""
    case $DATABASE in
        postgres)
        ADDITIONAL_STARTUP_SERVICES="$ADDITIONAL_STARTUP_SERVICES postgres"
        ;;
        hybrid)
        ADDITIONAL_STARTUP_SERVICES="$ADDITIONAL_STARTUP_SERVICES postgres cassandra"
        ;;
        *)
        echo "Unknown DATABASE value specified in the .env file: '${DATABASE}'. Should be either 'postgres' or 'hybrid'." >&2
        exit 1
    esac

    CACHE="${CACHE:-valkey}"
    case $CACHE in
        valkey)
        ADDITIONAL_STARTUP_SERVICES="$ADDITIONAL_STARTUP_SERVICES valkey"
        ;;
        valkey-cluster)
        ADDITIONAL_STARTUP_SERVICES="$ADDITIONAL_STARTUP_SERVICES valkey-node-0 valkey-node-1 valkey-node-2 valkey-node-3 valkey-node-4 valkey-node-5"
        ;;
        valkey-sentinel)
        ADDITIONAL_STARTUP_SERVICES="$ADDITIONAL_STARTUP_SERVICES valkey-primary valkey-replica valkey-sentinel"
        ;;
        *)
        echo "Unknown CACHE value specified in the .env file: '${CACHE}'. Should be either 'valkey' or 'valkey-cluster' or 'valkey-sentinel'." >&2
        exit 1
    esac

    echo $ADDITIONAL_STARTUP_SERVICES
}

function permissionList() {
    PERMISSION_LIST="
      799  799  tb-node/log
      799  799  tb-transports/lwm2m/log
      799  799  tb-transports/http/log
      799  799  tb-transports/mqtt/log
      799  799  tb-transports/snmp/log
      799  799  tb-transports/coap/log
      799  799  tb-vc-executor/log
      999  999  tb-node/postgres
      799  799  tb-report/log
      "

    PERMISSION_LIST="$PERMISSION_LIST
      799  799  tb-node/data
      799  799  tb-integration-executor/log
      "

    source .env

    if [ "$DATABASE" = "hybrid" ]; then
      PERMISSION_LIST="$PERMISSION_LIST
      999  999  tb-node/cassandra
      "
    fi

    if [ "$EDQS_ENABLED" = true ]; then
      PERMISSION_LIST="$PERMISSION_LIST
      799  799  tb-edqs/log
      "
    fi

    CACHE="${CACHE:-valkey}"
    case $CACHE in
        valkey)
          PERMISSION_LIST="$PERMISSION_LIST
          1001 1001 tb-node/valkey-data
          "
        ;;
        valkey-cluster)
          PERMISSION_LIST="$PERMISSION_LIST
          1001 1001 tb-node/valkey-cluster-data-0
          1001 1001 tb-node/valkey-cluster-data-1
          1001 1001 tb-node/valkey-cluster-data-2
          1001 1001 tb-node/valkey-cluster-data-3
          1001 1001 tb-node/valkey-cluster-data-4
          1001 1001 tb-node/valkey-cluster-data-5
          "
        ;;
        valkey-sentinel)
          PERMISSION_LIST="$PERMISSION_LIST
          1001 1001 tb-node/valkey-sentinel-data-primary
          1001 1001 tb-node/valkey-sentinel-data-replica
          1001 1001 tb-node/valkey-sentinel-data-sentinel
          "
        ;;
        *)
        echo "Unknown CACHE value specified in the .env file: '${CACHE}'. Should be either 'valkey' or 'valkey-cluster' or 'valkey-sentinel'." >&2
        exit 1
    esac

    echo "$PERMISSION_LIST"
}

function checkFolders() {
  CREATE=false
  SKIP_CHOWN=false
  for i in "$@"
    do
      case $i in
          --create)
          CREATE=true
          shift
          ;;
          --skipChown)
          SKIP_CHOWN=true
          shift
          ;;
          *)
                  # unknown option
          ;;
      esac
    done
  EXIT_CODE=0
  PERMISSION_LIST=$(permissionList) || exit $?
  set -e
  while read -r USR GRP DIR
  do
    IS_EXIST_CHECK_PASSED=false
    IS_OWNER_CHECK_PASSED=false

    # skip empty lines
    if [ -z "$DIR" ]; then
          continue
    fi

    # checks section
    echo "Checking if dir ${DIR} exists..."
    if [[ -d "$DIR" ]]; then
      echo "> OK"
      IS_EXIST_CHECK_PASSED=true
      if [ "$SKIP_CHOWN" = false ]; then
        echo "Checking user ${USR} group ${GRP} ownership for dir ${DIR}..."
        if [[ $(ls -ldn "$DIR" | awk '{print $3}') -eq "$USR" ]] && [[ $(ls -ldn "$DIR" | awk '{print $4}') -eq "$GRP" ]]; then
          echo "> OK"
          IS_OWNER_CHECK_PASSED=true
        else
          echo "...ownership check failed"
          if [ "$CREATE" = false ]; then
            EXIT_CODE=1
          fi
        fi
      fi
    else
      echo "...does not exist"
      if [ "$CREATE" = false ]; then
        EXIT_CODE=1
      fi
    fi

    # create/chown section
    if [ "$CREATE" = true ]; then
      if [ "$IS_EXIST_CHECK_PASSED" = false ]; then
        echo "...will create dir ${DIR}"
        if [ "$SKIP_CHOWN" = false ]; then
        echo "...will change ownership to user ${USR} group ${GRP} for dir ${DIR}"
          mkdir -p "$DIR" && sudo chown -R "$USR":"$GRP" "$DIR" && echo "> OK"
        else
          mkdir -p "$DIR" && echo "> OK"
        fi
      elif [ "$IS_OWNER_CHECK_PASSED" = false ] && [ "$SKIP_CHOWN" = false ]; then
        echo "...will change ownership to user ${USR} group ${GRP} for dir ${DIR}"
        sudo chown -R "$USR":"$GRP" "$DIR" && echo "> OK"
      fi
    fi

  done < <(echo "$PERMISSION_LIST")
  return $EXIT_CODE
}

function checkComposeVersion() {
    # Check Docker CLI availability
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker is not installed or not available in PATH. Please install Docker." >&2
        return 1
    fi

    # Check Docker Compose v2+ availability (plugin)
    if ! docker compose version >/dev/null 2>&1; then
        echo "Docker Compose v2 or newer is required. 'docker compose' (the Compose plugin) was not detected. Please update Docker to the latest version." >&2
        return 1
    fi
    return 0
}

# Initialize Compose command on sourcing/executing this file
# Respect TB_SKIP_COMPOSE_CHECK=true to disable the check for helper scripts
if [ "${BASH_SOURCE[0]}" != "$0" ]; then
  # Sourced: return on failure
  if [ "${TB_SKIP_COMPOSE_CHECK}" != "true" ]; then
    checkComposeVersion || return $?
  fi
else
  # Executed directly: exit on failure
  if [ "${TB_SKIP_COMPOSE_CHECK}" != "true" ]; then
    checkComposeVersion || exit $?
  fi
fi

