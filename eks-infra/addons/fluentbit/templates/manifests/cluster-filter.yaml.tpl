---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterFilter
metadata:
  name: kubernetes
  labels:
    app.kubernetes.io/managed-by: Terraform
    fluentbit.fluent.io/component: logging
    fluentbit.fluent.io/enabled: 'true'
spec:
  match: kube.*
  filters:
  - kubernetes:
      annotations: false
      keepLog: false
      mergeLog: true
      k8sLoggingExclude: true
  - nest:
      addPrefix: kubernetes_
      nestedUnder: kubernetes
      operation: lift
  - modify:
      rules:
      - remove: stream
      - remove: time
      - remove: kubernetes_pod_id
      - remove: kubernetes_host
      - remove: kubernetes_container_hash
  - nest:
      nestUnder: kubernetes
      operation: nest
      removePrefix: kubernetes_
      wildcard:
      - kubernetes_*
