Create S3 bucket and enable versioning on it:
```
$ aws s3api create-bucket \
      --bucket my-tf-state \
      --region us-east-1
```
Note: S3 requires `--create-bucket-configuration LocationConstraint=<region>` for regions other than us-east-1.

```
$ aws s3api put-bucket-versioning \
      --bucket my-tf-state \
      --versioning-configuration Status=Enabled
```
Create DynamoDB table for remote Terraform locks:
```
$ aws dynamodb create-table \
      --region us-east-1 \
      --table-name my-inf-tflock \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Links:    
https://github.com/hashicorp/terraform/issues/12877#issuecomment-311649591    
https://medium.com/@jessgreb01/how-to-terraform-locking-state-in-s3-2dc9a5665cb6
    
    
Get latest AMI image (for example for Ubuntu):
```
data "aws_ami" "ubuntu-latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
```
