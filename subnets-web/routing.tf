resource "aws_route_table" "my-public-routes" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name      = "my-public-routes"
    Terraform = 1
  }
}

resource "aws_route" "route-to-internet-gateway" {
  route_table_id         = aws_route_table.my-public-routes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my-internet-gw.id
}

resource "aws_route_table_association" "my-public-subnet" {
  subnet_id      = aws_subnet.my-public-subnet.id
  route_table_id = aws_route_table.my-public-routes.id
}

resource "aws_route_table" "my-private-routes" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name      = "my-private-routes"
    Terraform = 1
  }
}

resource "aws_route" "route-to-nat-gateway" {
  route_table_id         = aws_route_table.my-private-routes.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my-private-subnet-nat.id
}

resource "aws_route_table_association" "my-private-subnet" {
  subnet_id      = aws_subnet.my-private-subnet.id
  route_table_id = aws_route_table.my-private-routes.id
}
