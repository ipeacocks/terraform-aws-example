---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterOutput
metadata:
  name: es
  labels:
    app.kubernetes.io/managed-by: Terraform
    fluentbit.fluent.io/component: logging
    fluentbit.fluent.io/enabled: 'true'
spec:
  matchRegex: (?:kube|service)\.(.*)
  es:
    compress: gzip
    bufferSize: 1MB
    generateID: true
    host: ${es_host}
    logstashFormat: true
    port: 9200
    timeKey: '@timestamp'
    suppressTypeName: 'On'
    logstashPrefix: unknown
    logstashPrefixKey: kubernetes['labels']['app.kubernetes.io/name']
