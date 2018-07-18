resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = "${var.public-key}"
}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.ami-image, var.region)}"

  # ami                  = "${data.aws_ami.ubuntu-latest.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.my-public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
  key_name               = "${aws_key_pair.my-key.key_name}"

  tags {
    Name      = "bastion"
    Terraform = 1
  }
}

resource "aws_eip" "bastion-eip" {
  instance   = "${aws_instance.bastion.id}"
  depends_on = ["aws_instance.bastion"]

  tags {
    Name      = "bastion-eip"
    Terraform = 1
  }
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = "${lookup(var.ami-image, var.region)}"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.my-private-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = "${aws_key_pair.my-key.key_name}"

  tags {
    Name      = "web-${count.index}"
    Terraform = 1
  }

  user_data = <<-EOF
            #!/bin/bash
            echo "<h1>Say hello to Terraform from web-${count.index}</h1>" > index.html
            nohup busybox httpd -f -p 8080 &
            EOF

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
}

resource "aws_elb" "web-elb" {
  name            = "web-elb"
  subnets         = ["${aws_subnet.my-public-subnet.id}"]
  security_groups = ["${aws_security_group.web-elb-sg.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 4
    target              = "TCP:8080"
    interval            = 30
  }

  instances                   = ["${aws_instance.web.*.id}"]
  idle_timeout                = 90
  connection_draining         = true
  connection_draining_timeout = 90

  tags {
    Name      = "web-elb"
    Terraform = 1
  }
}
