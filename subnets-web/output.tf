output "my-vpc-id" {
  value = "${aws_vpc.my-vpc.id}"
}

output "my-public-subnet-id" {
  value = "${aws_subnet.my-public-subnet.id}"
}

output "my-private-subnet-id" {
  value = "${aws_subnet.my-private-subnet.id}"
}

output "bastion-eip" {
  value = "${aws_eip.bastion-eip.public_ip}"
}

output "web-elb" {
  value = "${aws_elb.web-elb.dns_name}"
}
