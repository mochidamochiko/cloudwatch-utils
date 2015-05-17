#!/bin/bash

usage() {
  echo "getmetrics.sh <targetdate(yyyymmdd)> <namespace(exclude AWS/)> <metricname> <statistics> <dementions>"
  exit 1
}

debug_log() {
    if [ -e debug_on ]; then
        echo "DEBUG: $1"
    fi
}

# Option解析
NAMESPACE=$2
METRICNAME=$3
STATISTICS=$4
if [ -z "${STATISTICS}" ]; then
  STATISTICS=ALL
fi

debug_log "NAMESPACE=${NAMESPACE}"
debug_log "METRICNAME=${METRICNAME}"
debug_log "STATISTICS=${STATISTICS}"

TargetDate=$1
if [ `uname` = "Darwin" ];then
  STARTTIME=`date -j -v-9H -f %Y%m%d%H%M%S ${TargetDate}000000 +%Y-%m-%dT%TZ`
  ENDTIME=`date -j -v+15H -f %Y%m%d%H%M%S ${TargetDate}000000 +%Y-%m-%dT%TZ`
else
  STARTTIME=`date -u -d "${TargetDate} - 9hours " +%Y-%m-%dT%TZ`
  ENDTIME=`date -u -d "${TargetDate} + 21hours " +%Y-%m-%dT%TZ`
fi
PERIOD=60

debug_log "STARTTIME=${STARTTIME}"
debug_log "ENDTIME=${ENDTIME}"
debug_log "PERIOD=${PERIOD}"

ResourceName=$5
if [ ! -z "${ResourceName}" ]; then
  DementionsList=conf/dementions-${NAMESPACE}.lst
  debug_log "DementionsList=${DementionsList}"

  # ディメンションを設定
  for line in `cat "${DementionsList}"`; do
    if [ -z "${line}" ]; then
      continue
    fi

    DEMENTIONS="Name=${line},Value=${ResourceName}"
    debug_log "DEMENTIONS=${DEMENTIONS}"
  done
fi

get_metrics() {
  STATISTICS=$1
  debug_log "STATISTICS=${STATISTICS}"

  # メトリクスファイル名
  if [ ! -e metrics ]; then 
    mkdir metrics
  fi
  if [ -z "${ResourceName}" ]; then
    OutputFileName=metrics/${TargetDate}_${NAMESPACE}_${METRICNAME}_${STATISTICS}.json
  else
    OutputFileName=metrics/${TargetDate}_${NAMESPACE}_${ResourceName}_${METRICNAME}_${STATISTICS}.json
  fi
  debug_log "OutputFileName=${OutputFileName}"

  # AWSコマンド
  AwsCmd="aws cloudwatch get-metric-statistics \
    --namespace AWS/${NAMESPACE} \
    --metric-name ${METRICNAME} \
    --start-time ${STARTTIME} \
    --end-time ${ENDTIME} \
    --period ${PERIOD} \
    --statistics ${STATISTICS}"
  if [ ! -z "${DEMENTIONS}" ]; then
    AwsCmd="${AwsCmd} --dimensions ${DEMENTIONS}"
  fi
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

