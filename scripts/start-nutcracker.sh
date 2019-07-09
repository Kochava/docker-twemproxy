#!/bin/bash
# Copyright 2019 Rob Lyon (ctxswitch)
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
# limitations under the License.
set -e

TWEMPROXY_VERBOSE=${TWEMPROXY_VERBOSE:-5}
TWEMPROXY_STATS_PORT=${TWEMPROXY_STATS_PORT:-22222}
TWEMPROXY_STATS_ADDRESS=${TWEMPROXY_STATS_ADDRESS:-127.0.0.1}
TWEMPROXY_MBUF_SIZE=${TWEMPROXY_MBUF_SIZE:-16384}
TWEMPROXY_STATS_INTERVAL=${TWEMPROXY_STATS_INTERVAL:-30000}

# If we are not defining a config, then we need to dynamically create if from the
# passed environment.
if [ -z $TWEMPROXY_CONFIG ] ; then
  TWEMPROXY_LISTEN=${TWEMPROXY_LISTEN:-127.0.0.1:11211}
  TWEMPROXY_HASH=${TEMPROXY_HASH:-fnv1a_64}
  TWEMPROXY_DISTRIBUTION=${TWEMPROXY_DISTRIBUTION:-ketama}
  TWEMPROXY_AUTO_EJECT_HOSTS=${TWEMPROXY_AUTO_EJECT_HOSTS:-true}
  TWEMPROXY_SERVER_RETRY_TIMEOUT=${TWEMPROXY_SERVER_RETRY_TIMEOUT:-30000}
  TWEMPROXY_SERVER_FAILURE_LIMIT=${TWEMPROXY_SERVER_FAILURE_LIMIT:-2}
  TWEMPROXY_TIMEOUT=${TWEMPROXY_TIMEOUT:-60000}
  TWEMPROXY_BACKLOG=${TWEMPROXY_BACKLOG:-512}
  TWEMPROXY_PRECONNECT=${TWEMPROXY_PRECONNECT:-false}
  TWEMPROXY_REDIS=${TWEMPROXY_REDIS:-false}
  if [ -z $TWEMPROXY_SERVERS ] ; then
    echo "TWEMPROXY_SERVERS must be defined and contain a comma seperated list of servers:ports:priority values.  e.g. 10.0.0.1:11211:1,10.0.0.2:11211:1,10.0.0.3:11211:1"
    exit 1
  fi

  cat > /etc/nutcracker.yml << EOF
nutcracker:
  listen: $TWEMPROXY_LISTEN
  hash: $TWEMPROXY_HASH
  distribution: $TWEMPROXY_DISTRIBUTION
  auto_eject_hosts: $TWEMPROXY_AUTO_EJECT_HOSTS
  server_retry_timeout: $TWEMPROXY_SERVER_RETRY_TIMEOUT
  server_failure_limit: $TWEMPROXY_SERVER_FAILURE_LIMIT
  timeout: $TWEMPROXY_TIMEOUT
  backlog: $TWEMPROXY_BACKLOG
  preconnect: $TWEMPROXY_PRECONNECT
EOF

  if [ "$TWEMPROXY_REDIS" == "true" ] ; then
    echo "  redis: true" >> /etc/nutcracker.yml
    if ! [ -z $TWEMPROXY_REDIS_DB ] ; then
      echo "  redis_db: $TWEMPROXY_REDIS_DB" >> /etc/nutcracker.yml
    fi
    if ! [ -z $TWEMPROXY_REDIS_AUTH ] ; then
      echo "  redis_db: $TWEMPROXY_REDIS_AUTH" >> /etc/nutcracker.yml
    fi
  fi

  echo "  servers:" >> /etc/nutcracker.yml
  while IFS=, read server ; do
    echo "    - $server" >> /etc/nutcracker.yml
  done <<< "$TWEMPROXY_SERVERS"
fi

CONFFILE=${TWEMPROXY_CONFIG:-/etc/nutcracker.yml}
/usr/sbin/nutcracker \
    --verbose=$TWEMPROXY_VERBOSE \
    --stats-port=$TWEMPROXY_STATS_PORT \
    --stats-addr=$TWEMPROXY_STATS_ADDRESS \
    --stats-interval=$TWEMPROXY_STATS_INTERVAL \
    --mbuf-size=$TWEMPROXY_MBUF_SIZE \
    --conf-file=$CONFFILE
