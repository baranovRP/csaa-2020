resource "aws_vpc" "tf_vpc_environment" {
  cidr_block                       = var.cidrblocks.cidrblock_vpc
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "tfVPC"
  }
}

resource "aws_subnet" "tf_subnet1" {
  cidr_block              = cidrsubnet(aws_vpc.tf_vpc_environment.cidr_block, 8, 1)
  vpc_id                  = aws_vpc.tf_vpc_environment.id
  availability_zone       = var.availability_zones.zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "10.0.1.0 - eu-central-1a"
  }
}

resource "aws_subnet" "tf_subnet2" {
  cidr_block        = cidrsubnet(aws_vpc.tf_vpc_environment.cidr_block, 8, 2)
  vpc_id            = aws_vpc.tf_vpc_environment.id
  availability_zone = var.availability_zones.zone2

  tags = {
    Name = "10.0.2.0 - eu-central-1b"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc_environment.id

  tags = {
    Name = "tfIGW"
  }
}

resource "aws_route_table" "tf_public_route" {
  vpc_id = aws_vpc.tf_vpc_environment.id

  route {
    cidr_block = var.cidrblocks.cidrblock_all
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  route {
    ipv6_cidr_block = var.cidrblocks.cidrblock_all_ipv6
    gateway_id      = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "tfPublicRoute"
  }
}

resource "aws_route_table_association" "tf_route_table_association" {
  subnet_id      = aws_subnet.tf_subnet1.id
  route_table_id = aws_route_table.tf_public_route.id
}
