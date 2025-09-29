# This is only controller SA, dashboard has own parameters
serviceAccount:
  create: true

controller:
  extraArgs: ["--aws-verify-target-group"]
  extraEnv:
    - name: AWS_REGION
      value: ${region}
  replicas: 2
  metrics:
    enabled: true
  logging:
    format: "json"

keepCRDs: false

dashboard:
  enabled: true
  replicas: 2

  # ingress:
  #   enabled: true
  #   annotations:
  #     alb.ingress.kubernetes.io/group.name: eks-addons
  #     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
  #     alb.ingress.kubernetes.io/scheme: internet-facing
  #     alb.ingress.kubernetes.io/success-codes: "200-302"
  #     alb.ingress.kubernetes.io/target-type: ip
  #     external-dns.alpha.kubernetes.io/hostname: rollouts-dashboard.example.com
  #     alb.ingress.kubernetes.io/healthcheck-port: traffic-port
  #   ingressClassName: "alb"
  #   hosts:
  #     - example.com
  #   paths:
  #     - /
  #   pathType: Prefix
