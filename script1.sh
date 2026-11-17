#!/bin/bash
# Usuwa stare ReplicaSety Deploymentów, zostawiając najnowsze
# nieaktywne wersje na każdy Deployment (żeby działał rollout undo).
# Sterowane parametrem KEEP

set -euo pipefail

export PATH=/usr/local/bin:/usr/bin:/bin
export KUBECONFIG=/root/.kube/config      

KEEP=3                                    # WAZNE - liczba starych replicaset dla kazdego deploymentu ktore maja zostac

kubectl get rs --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.metadata.ownerReferences[0].kind}{"\t"}{.metadata.ownerReferences[0].name}{"\t"}{.metadata.annotations.deployment\.kubernetes\.io/revision}{"\t"}{.spec.replicas}{"\t"}{.status.replicas}{"\n"}{end}' \
| awk -F'\t' -v OFS='\t' '
    $3 == "Deployment" && ($6 == "" || $6 == 0) && ($7 == "" || $7 == 0) {
      print $1, $4, ($5 == "" ? 0 : $5), $2
    }' \
| sort -t$'\t' -k1,1 -k2,2 -k3,3nr \
| awk -F'\t' -v keep="$KEEP" '{ if (++count[$1 "/" $2] > keep) print $1, $4 }' \
| while read -r ns name; do
    kubectl delete rs -n "$ns" "$name" --ignore-not-found
  done
