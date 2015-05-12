#!/bin/bash

usage() {
  echo "getmetrics.sh <targetdate(yyyymmdd)> <namespace(exclude AWS/)> <dementions>"
  exit 1
}

debug_log() {
    if [ -e debug_on ]; then
        echo "DEBUG: $1"
    fi
}

# オプション解析
TargetDate=$1
NAMESPACE=$2
ResourceName=$3
STATISTICS=ALL
debug_log "NAMESPACE=${NAMESPACE}"
debug_log "TargetDate=${TargetDate}"
debug_log "ResourceName=${ResourceName}"
debug_log "STATISTICS=${STATISTICS}"

MetricsList=conf/metrics-${NAMESPACE}.lst
debug_log "MetricsList=${MetricsList}"

# メトリクス一覧の読み取り
cat "${MetricsList}" | while read line; do
  if [ -z "${line}" ]; then
    continue
  fi

  # メトリクスごとにgetmetrics.shをコール
  METRICNAME=${line}
  debug_log "METRICNAME=${METRICNAME}"

  debug_log "Call getmetrics.sh with ${METRICNAME}"
  ./getmetrics.sh ${TargetDate} ${NAMESPACE} ${METRICNAME} ${STATISTICS} ${ResourceName}
done

