apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: generic
  annotations:
    kubernetes.io/description: "General purpose EC2NodeClass for running AL 2023 nodes"
spec:
  amiSelectorTerms:
    - alias: al2023@v20250403
  metadataOptions:
    httpEndpoint: enabled
    httpPutResponseHopLimit: 2
    httpTokens: required
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        deleteOnTermination: true
        encrypted: true
        throughput: 250
        volumeSize: 30Gi
        volumeType: gp3
  role: ${role}
  securityGroupSelectorTerms:
    - id: ${cluster_node_security_group_id}
  subnetSelectorTerms:
  %{ for subnet in split(",", private_subnets) }
    - id: ${subnet}
  %{ endfor }
  tags:
    Name: ${cluster_name}-eks-dynamic
    %{ for tag in split(",", tags) }
    ${tag}
  %{ endfor }
