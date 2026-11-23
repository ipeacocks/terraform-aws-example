data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "my-tf-state-2023-06-01"
    key    = "my-eks.tfstate"
    region = "us-east-1"
  }
}

# data "aws_caller_identity" "current" {}

locals {
  name = "${var.name_prefix}-${data.terraform_remote_state.eks.outputs.cluster_name}-${var.region}"
}

module "emr" {
  source  = "terraform-aws-modules/emr/aws//modules/virtual-cluster"
  version = "3.3.0"

  eks_cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
  eks_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

  name             = var.name_prefix
  create_namespace = true
  namespace        = var.name_prefix

  s3_bucket_arns = [
    module.s3_bucket.s3_bucket_arn,
    "${module.s3_bucket.s3_bucket_arn}/*"
  ]
  role_name                     = local.name
  iam_role_use_name_prefix      = false
  iam_role_path                 = "/"
  iam_role_description          = "EMR custom Role"
  iam_role_permissions_boundary = null
  iam_role_additional_policies  = {}

  tags = var.tags
}

# Sample Spark Job
resource "null_resource" "s3_sync" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = var.region
    }

    # Sync to a bucket that we can provide access to (see `s3_bucket_arns` above)
    command = <<-EOT
      aws s3 sync s3://aws-data-analytics-workshops/emr-eks-workshop/scripts/ s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/
    EOT
  }
}

resource "null_resource" "start_job_run" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = var.region
    }

    command = <<-EOT
      aws emr-containers start-job-run \
      --virtual-cluster-id ${module.emr.virtual_cluster_id} \
      --name ${local.name}-example \
      --execution-role-arn ${module.emr.job_execution_role_arn} \
      --release-label emr-7.9.0-latest \
      --job-driver '{
          "sparkSubmitJobDriver": {
              "entryPoint": "s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/pi.py",
              "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
              }
          }' \
      --configuration-overrides '{
          "applicationConfiguration": [
            {
              "classification": "spark-defaults",
              "properties": {
                "spark.driver.memory":"2G"
              }
            }
          ],
          "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
              "logGroupName": "${module.emr.cloudwatch_log_group_name}",
              "logStreamNamePrefix": "eks-blueprints"
            }
          }
        }'
    EOT
  }
}

# Supporting Resources
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.18.0"

  bucket_prefix = "${var.name_prefix}-"

  # Allow deletion of non-empty bucket
  # Example usage only - not recommended for production
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}
