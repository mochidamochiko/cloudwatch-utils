#!/bin/bash

usage() {
  echo "getmetrics.sh <namespace(exclude AWS/)> <targetdate(yyyymmdd)> <metricname> <statistics>"
  exit 1
}

debug_log() {
    if [ -e debug_on ]; then
        echo "DEBUG: $1"
    fi
}

# Option解析
NAMESPACE=$1
METRICNAME=$3
STATISTICS=$4
if [ -z "${STATISTICS}" ]; then
  STATISTICS=ALL
fi

debug_log "NAMESPACE=${NAMESPACE}"
debug_log "METRICNAME=${METRICNAME}"
debug_log "STATISTICS=${STATISTICS}"


TargetDate=$2
STARTTIME=`date -j -v-9H -f %Y%m%d%H%M%S ${TargetDate}000000 +%Y-%m-%dT%TZ`
ENDTIME=`date -j -v+21H -f %Y%m%d%H%M%S ${TargetDate}000000 +%Y-%m-%dT%TZ`
PERIOD=300

debug_log "STARTTIME=${STARTTIME}"
debug_log "ENDTIME=${ENDTIME}"
debug_log "PERIOD=${PERIOD}"

get_metrics() {
  STATISTICS=$1
  debug_log "STATISTICS=${STATISTICS}"

  # メトリクスファイル名
  if [ ! -e metrics ]; then 
    mkdir metrics
  fi
  OutputFileName=metrics/${TargetDate}_${NAMESPACE}_${METRICNAME}_${STATISTICS}.json
  debug_log "OutputFileName=${OutputFileName}"

  # AWSコマンド
  AwsCmd="aws cloudwatch get-metric-statistics \
    --namespace AWS/${NAMESPACE} \
    --metric-name ${METRICNAME} \
    --start-time ${STARTTIME} \
    --end-time ${ENDTIME} \
    --period ${PERIOD} \
    --statistics ${STATISTICS}"
  debug_log "${AwsCmd}"

  ${AwsCmd} > ${OutputFileName}
}

if [ ${STATISTICS} = "ALL" ]; then
  debug_log "Call all statistics"
  get_metrics Average
  get_metrics Sum
  get_metrics SampleCount
  get_metrics Maximum
  get_metrics Minimum
else
  get_metrics ${STATISTICS}
fi

