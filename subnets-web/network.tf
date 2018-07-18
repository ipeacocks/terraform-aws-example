# Declare the data source
# All available zones (AZ) list
data "aws_availability_zones" "available" {}

resource "aws_vpc" "my-vpc" {
  cidr_block = "${var.vpc-cidr}"

  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name      = "my-vpc"
    Terraform = 1
  }
}

resource "aws_subnet" "my-public-subnet" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "${var.subnet-public-cidr}"

  tags {
    Name      = "my-public-subnet"
    Terraform = 1
  }

  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "my-private-subnet" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "${var.subnet-private-cidr}"

  tags {
    Name      = "my-private-subnet"
    Terraform = 1
  }

  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_internet_gateway" "my-internet-gw" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags {
    Name      = "my-internet-gateway"
    Terraform = 1
  }
}

resource "aws_eip" "my-private-subnet-nat-eip" {
  vpc = true

  tags {
    Name      = "my-private-subnet-nat-eip"
    Terraform = 1
  }
}

# EIP of NAT Gateway needs to be in public network
resource "aws_nat_gateway" "my-private-subnet-nat" {
  allocation_id = "${aws_eip.my-private-subnet-nat-eip.id}"
  subnet_id     = "${aws_subnet.my-public-subnet.id}"
  depends_on    = ["aws_internet_gateway.my-internet-gw"]

  tags {
    Name      = "my-private-subnet-nat"
    Terraform = 1
  }
}
