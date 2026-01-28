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

set -e

URL_NO_PREFIX="${SPRING_DATASOURCE_URL#jdbc:postgresql://}"
HOST_PORT="${URL_NO_PREFIX%%/*}"
DB_NAME="${URL_NO_PREFIX#*/}"
HOST="${HOST_PORT%%:*}"
PORT="${HOST_PORT##*:}"
PORT="${PORT:-5432}"

export PGPASSWORD="${SPRING_DATASOURCE_PASSWORD}"

echo "Waiting for Postgres at ${HOST}:${PORT}..."
until pg_isready -h "${HOST}" -p "${PORT}" -U "${SPRING_DATASOURCE_USERNAME}"; do
  sleep 2
done

EXISTS=$(psql -h "${HOST}" -p "${PORT}" -U "${SPRING_DATASOURCE_USERNAME}" -d postgres -tAc \
  "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}';" || true)

if [ "${EXISTS}" = "1" ]; then
  echo "Database '${DB_NAME}' already exists"
else
  echo "Creating database '${DB_NAME}'..."
  psql -h "${HOST}" -p "${PORT}" -U "${SPRING_DATASOURCE_USERNAME}" -d postgres \
    -c "CREATE DATABASE \"${DB_NAME}\";"
fi

echo "done"
