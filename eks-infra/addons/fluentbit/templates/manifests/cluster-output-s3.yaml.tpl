---
apiVersion: fluentbit.fluent.io/v1alpha2
kind: ClusterOutput
metadata:
  name: s3-fluent-bit
  labels:
    app.kubernetes.io/managed-by: Terraform
    fluentbit.fluent.io/component: logging
    fluentbit.fluent.io/enabled: 'true'
spec:
  match: fluentbit.*
  s3:
    Region: us-east-1
    Bucket: fluentbit-logs-2026
    S3KeyFormat: /%Y-%m-%d-%H_$UUID.log
    ContentType: text/plain
    TotalFileSize: 45M
    UploadTimeout: 1m
    UsePutObject: true
    StoreDir: /fluentbit/buffer/s3
    StoreDirLimitSize: 2G
    JsonDateKey: '@timestamp'
    JsonDateFormat: iso8601
    PreserveDataOrdering: true
    RetryLimit: 5
