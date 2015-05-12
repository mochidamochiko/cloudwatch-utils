#!/bin/bash

usage() {
  echo "getmetrics.sh <namespace(exclude AWS/)> <targetdate(yyyymmdd)>"
  exit 1
}

debug_log() {
    if [ -e debug_on ]; then
        echo "DEBUG: $1"
    fi
}

# オプション解析
NAMESPACE=$1
TargetDate=$2
debug_log "NAMESPACE=${NAMESPACE}"
debug_log "TargetDate=${TargetDate}"

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
  ./getmetrics.sh ${NAMESPACE} ${TargetDate} ${METRICNAME}
done

