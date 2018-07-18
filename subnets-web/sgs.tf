# SG for bastion (ssh host)

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-sg"
  vpc_id = "${aws_vpc.my-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "bastion-sg"
    Terraform = 1
  }
}

resource "aws_security_group_rule" "allow_bastion_ssh_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion-sg.id}"

  from_port   = "22"
  to_port     = "22"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_bastion_icmp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion-sg.id}"

  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_bastion_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion-sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# SG for web servers

resource "aws_security_group" "web-sg" {
  name   = "web-sg"
  vpc_id = "${aws_vpc.my-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "web-sg"
    Terraform = 1
  }
}

resource "aws_security_group_rule" "allow_web_ssh_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.web-sg.id}"

  from_port   = "22"
  to_port     = "22"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow traffic only from ELB on 8080 port
resource "aws_security_group_rule" "allow_web_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.web-sg.id}"

  from_port                = "8080"
  to_port                  = "8080"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.web-elb-sg.id}"
}

resource "aws_security_group_rule" "allow_web_icmp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.web-sg.id}"

  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_web_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.web-sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# SG for ELB web-elb

resource "aws_security_group" "web-elb-sg" {
  name   = "web-elb-sg"
  vpc_id = "${aws_vpc.my-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name      = "web-elb-sg"
    Terraform = 1
  }
}

resource "aws_security_group_rule" "allow_web-elb_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.web-elb-sg.id}"

  from_port   = "80"
  to_port     = "80"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_web-elb_icmp_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.web-elb-sg.id}"

  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_web-elb_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.web-elb-sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
