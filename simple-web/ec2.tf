resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = "${var.public-key}"
}

resource "aws_instance" "web" {
  # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type in us-east-1
  ami                    = "ami-0044130ca185d0880"
  instance_type          = "t2.medium"
  key_name               = "${aws_key_pair.my-key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]

  tags = {
    Name = "web"
  }

  user_data = <<-EOF
            #!/bin/bash
            echo "<h1>Say hello to Terraform</h1>" > index.html
            nohup busybox httpd -f -p 8080 &
            EOF
}

# We wish to output public IP to bash
output "web_public_ip" {
  value = "${aws_instance.web.public_ip}"
}
