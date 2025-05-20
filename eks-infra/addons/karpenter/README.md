### Test deployment:

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                - arm64
      terminationGracePeriodSeconds: 0
      securityContext:
        runAsUser: 1000
        runAsGroup: 3000
        fsGroup: 2000
      containers:
      - name: inflate
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        resources:
          requests:
            cpu: 1
        nodeSelector:
          node-type: dynamic
        securityContext:
          allowPrivilegeEscalation: false
      tolerations:
      - effect: NoSchedule
        key: your.company.io/workloads
        operator: Exists
      - effect: NoExecute
        key: your.company.io/workloads
        operator: Exists
      topologySpreadConstraints:
      - labelSelector:
          matchLabels:
            app: inflate
        maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: ScheduleAnyway
      - labelSelector:
          matchLabels:
            app: inflate
        maxSkew: 1
        topologyKey: kubernetes.io/hostname
        whenUnsatisfiable: ScheduleAnyway
EOF
```

### Karpenter budgets.
Enables `Drifted` and `Underutilized` disruptions from 9-11 and 15-17 UTC on weekdays only. Always enables `Empty` disruptions.
```yaml
# weekends (working and easy to understand)
  disruption:
    budgets:
    - nodes: "1"
      reasons:
      - Empty

    - duration: 2h
      nodes: "1"
      reasons:
      - Drifted
      - Underutilized
      schedule: 0 9 * * mon-fri

    - duration: 4h
      nodes: "0"
      reasons:
      - Drifted
      - Underutilized
      schedule: 0 11 * * mon-fri

    - duration: 2h
      nodes: "1"
      reasons:
      - Drifted
      - Underutilized
      schedule: 0 15 * * mon-fri

    - duration: 16h
      nodes: "0"
      reasons:
      - Drifted
      - Underutilized
      schedule: 0 17 * * sun-sat

    - duration: 8h
      nodes: "0"
      reasons:
      - Drifted
      - Underutilized
      schedule: 0 9 * * sat,sun
```
```yaml
# working too but harder to get
disruption:
  budgets:
  - nodes: "1"

  - nodes: "0"
    schedule: 0 11 * *  mon-fri
    duration: 4h
    reasons:
    - Drifted
    - Underutilized

  - nodes: "0"
    schedule: 0 17 * * sun-sat
    duration: 16h
    reasons:
    - Drifted
    - Underutilized
    
  - nodes: "0"
    schedule: 0 9 * * sat,sun
    duration: 8h
    reasons:
    - Drifted
    - Underutilized
``` 
```yaml
# not working (tested)
disruption:
  budgets:
  - nodes: "0"
    reasons:
    - Drifted
    - Underutilized

  - nodes: "1"
    reasons:
    - Empty

  - nodes: "1"
    schedule: 0 9 * * mon-fri
    duration: 2h
    reasons:
    - Drifted
    - Underutilized

  - nodes: "1"
    schedule: 0 15 * * mon-fri
    duration: 2h
    reasons:
    - Drifted
    - Underutilized
```
```yaml
# maybe working (not tested)
disruption:
  budgets:
  - nodes: "0"
    reasons:
    - Drifted
    - Underutilized

  - nodes: "1"
    duration: 24h
    schedule: 0 0 * * *
    reasons:
    - Empty

  - nodes: "1"
    schedule: 0 9 * * mon-fri
    duration: 2h
    reasons:
    - Drifted
    - Underutilized

  - nodes: "1"
    schedule: 0 15 * * mon-fri
    duration: 2h
    reasons:
    - Drifted
    - Underutilized
```
