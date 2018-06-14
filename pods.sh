#!/bin/bash
NAMESPACES=$1

function getPods {
  PODS=`kubectl get pods $* -o json | jq '[.items[] | { pod: .metadata.name, node: .spec.nodeName, namespace: .metadata.namespace, status: .status.conditions[] | select(.status=="False") } | select( now - (.status.lastTransitionTime | fromdateiso8601) > 300 )] | map({ namespace: .namespace, pod: .pod }) | group_by(.namespace) | map({ namespace: .[0].namespace, pods: [.[].pod] })'`

  if [ ${#PODS} -gt 2 ]; then
    echo "unhealthy pods: "
    echo $PODS | jq -r '.[] | "namespace: \(.namespace): \(.pods) pods"'
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
