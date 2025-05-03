controller:
  resources:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 1
      memory: 1Gi
  metrics:
    port: 8000
settings:
  clusterName: ${clusterName}
  interruptionQueue: ${interruptionQueueName}
