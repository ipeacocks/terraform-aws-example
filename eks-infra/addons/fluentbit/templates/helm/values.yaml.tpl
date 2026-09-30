containerRuntime: containerd
Kubernetes: true

operator:
  resources:
    limits:
      cpu: 200m
      memory: 300Mi
    requests:
      cpu: 200m
      memory: 150Mi

fluentbit:
  resources:
    limits:
      cpu: ${limits.cpu}
      memory: ${limits.memory}
    requests:
      cpu: ${requests.cpu}
      memory: ${requests.memory}

  filter:
    kubernetes:
      enable: false
