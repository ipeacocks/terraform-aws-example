Link: https://github.com/terraform-aws-modules/terraform-aws-emr/blob/master/examples/virtual-cluster/main.tf

```
aws emr-containers start-job-run \
  --virtual-cluster-id hdaal908c1k8ss9fu93hvl1r1 \
  --name virtual-emr-my-eks-us-east-1-example \
  --execution-role-arn arn:aws:iam::789248082627:role/virtual-emr-my-eks-us-east-1 \
  --release-label emr-7.9.0-latest \
  --job-driver '{
      "sparkSubmitJobDriver": {
          "entryPoint": "s3://virtual-emr-92e9750952d573be4c5c8a7070/emr-eks-workshop/scripts/pi.py",
          "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=1G --conf spark.executor.cores=1 --conf spark.driver.cores=1"

          }
      }' \
  --configuration-overrides '{
      "applicationConfiguration": [
        {
          "classification": "spark-defaults",
          "properties": {
            "spark.driver.memory":"1G",
            "spark.kubernetes.driver.podTemplateFile": "s3://virtual-emr-92e9750952d573be4c5c8a7070/spark-pod-template.yaml",
            "spark.kubernetes.executor.podTemplateFile": "s3://virtual-emr-92e9750952d573be4c5c8a7070/spark-pod-template.yaml"
          }
        }
      ],
      "monitoringConfiguration": {
        "cloudWatchMonitoringConfiguration": {
          "logGroupName": "emr-on-eks-logs/emr-workload/virtual-emr",
          "logStreamNamePrefix": "eks-blueprints"
        }
      }
    }'
```

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3Objects",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::virtual-emr-92e9750952d573be4c5c8a7070/*",
                "arn:aws:s3:::virtual-emr-92e9750952d573be4c5c8a7070"
            ]
        },
        {
            "Sid": "CloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:789248082627:log-group:emr-on-eks-logs/emr-workload/virtual-emr",
                "arn:aws:logs:us-east-1:789248082627:log-group:emr-on-eks-logs/emr-workload/virtual-emr:log-stream:*"
            ]
        },
        {
            "Sid": "CloudWatchLogsReadOnly",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups"
            ],
            "Resource": "*"
        }
    ]
}
```