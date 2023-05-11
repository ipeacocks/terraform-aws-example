resource "aws_vpc_dhcp_options" "my-dhcp" {
  domain_name         = var.dns-zone-name
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name      = "my-dhcp-server"
    Terraform = 1
  }
}

resource "aws_vpc_dhcp_options_association" "my-dhcp-attachment" {
  vpc_id          = aws_vpc.my-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.my-dhcp.id
}

/* DNS PART ZONE AND RECORDS */
resource "aws_route53_zone" "main" {
  name    = var.dns-zone-name
  comment = "Managed by Terraform"
}

resource "aws_route53_record" "web-domain" {
  # count   = aws_instance.web[count.index]
  count   = length(aws_instance.web)
  zone_id = aws_route53_zone.main.zone_id
  name    = "web-${count.index}.${var.dns-zone-name}"
  type    = "A"
  ttl     = "60"
  records = ["${element(aws_instance.web.*.private_ip, count.index)}"]
}
