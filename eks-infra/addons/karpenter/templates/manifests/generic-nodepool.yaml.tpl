apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: generic
  annotations:
    kubernetes.io/description: "General purpose NodePool for amd64/arm64 workloads"
spec:
  disruption:
    consolidationPolicy: ${disruption.consolidation_policy}
    consolidateAfter: ${disruption.consolidate_after}
  limits:
    cpu: 1k
  template:
    metadata:
      labels:
        node-type: dynamic
    spec:
      expireAfter: ${expire_after}
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: generic
      taints:
        - key: your.company.io/workloads
          effect: NoSchedule
        - key: your.company.io/workloads
          effect: NoExecute
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64", "arm64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["3"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: Gt
          values: ["${instance.min_cpu}"]
        - key: "karpenter.k8s.aws/instance-memory"
          operator: Gt
          values: ["${instance.min_memory}"]
