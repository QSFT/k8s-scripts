#!/bin/bash

function getPods {
  echo Checking \"$*\"
  PODS=`kubectl get pods $* -o json | jq '[.items[] | { name: .metadata.name, node: .spec.nodeName, status: .status.conditions[] | select(.status=="False") } | select( now - (.status.lastTransitionTime | fromdateiso8601) > 300 )] | group_by(.node) | map({ node: .[0].node, total: length })'`

  if [ ${#PODS} -gt 2 ]; then
    echo "unhealthy pods: "
    echo $PODS | jq -r '.[] | "\(.node)\t\(.total) pods"'
  else
    echo "All pods are healthy"
  fi
}

if [ ${#NAMESPACES} -eq 0 ]; then
  getPods "--all-namespaces"
else
  for n in ${NAMESPACES//,/ }; do
    getPods --namespace=$n
  done
fi
