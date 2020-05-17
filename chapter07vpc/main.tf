###
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
}

data "aws_availability_zones" "available" {
  all_availability_zones = true
}

data "aws_ami" "ami2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

/*
data "aws_ami" "nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}
*/

data "aws_security_group" "default" {
  vpc_id = aws_vpc.this.id
  name   = "default"
}

resource "aws_key_pair" "deployer" {
  key_name   = "atlantis"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfObcpiUJAYEGXnJ0FOcyTM6pFvs1tTFKhpuNWfE/sssk7oGnM2Kw3zdktg7Ykq/LV+tOlxl9VtBa9FN6BQmxMi/bW96c47rGYL8VMPCQ3e7Qa7mKjbx1coBcQg9gxaLpWA73oD41O2cHYit084SlS8BTiRl1f4Lc9nPKM9RKyOzC6zajyIBFLDjOcRgVkEVoEW8QYroAFLJwKuKqu9oI9HAuov0c1o99J4ASqKmC/rm/76d1Fhs83dXNhLldmme7aN7M7XKX+8NM7hPeJtG3LGuxOtVMmMOhPkqG7FbtFWhKuXvD5CdU/S7QkxGo3lkZE+cwrUqKWQmEB6t4lKkxB"
}

resource "aws_vpc" "this" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "acloudguruVPC"
  }
}

resource "aws_subnet" "public" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.this.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "10.0.1.0 - ${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_subnet" "private" {
  cidr_block           = "10.0.2.0/24"
  vpc_id               = aws_vpc.this.id
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = {
    Name = "10.0.1.0 - ${data.aws_availability_zones.available.names[1]}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.this.id
  }

  tags = {
    Name = "acloudguru public route"
  }
}

### NAT instance
/*
resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.public_nat.id
  }

  tags = {
    Name = "default"
  }
}
*/

/*
resource "aws_instance" "public_nat" {
  ami           = data.aws_ami.ami2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [
    aws_security_group.ssh_world.id,
    aws_security_group.web_world.id,
    aws_security_group.world.id
  ]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "acloudguru public nat ec2"
  }
}
*/
###

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_instance" "public" {
  ami           = data.aws_ami.ami2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [
    aws_security_group.ssh_world.id,
    aws_security_group.web_world.id,
    aws_security_group.world.id
  ]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "acloudguru public ec2"
  }
}

resource "aws_instance" "private" {
  ami           = data.aws_ami.ami2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [
    aws_security_group.icmp_private.id,
    aws_security_group.ssh_priv_private.id,
    aws_security_group.mysql_private.id,
    aws_security_group.web_private.id,
    aws_security_group.web_secure_private.id,
    aws_security_group.world.id
  ]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = false

  tags = {
    Name = "acloudguru private ec2"
  }
}

resource "aws_security_group" "ssh_world" {
  name   = "ssh"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh_world.id

  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "web_world" {
  name   = "web"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_web" {
  type              = "ingress"
  security_group_id = aws_security_group.web_world.id

  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "world" {
  name   = "world-out"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  security_group_id = aws_security_group.world.id

  from_port        = 0
  to_port          = 0
  protocol         = -1
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group" "icmp_private" {
  name   = "icmp_priv"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.icmp_private.id

  from_port   = -1
  to_port     = -1
  protocol    = "ICMP"
  cidr_blocks = ["10.0.1.0/24"]
}

resource "aws_security_group" "web_private" {
  name   = "web_priv"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_web_priv" {
  type              = "ingress"
  security_group_id = aws_security_group.web_private.id

  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["10.0.1.0/24"]
}

resource "aws_security_group" "web_secure_private" {
  name   = "web_secure_priv"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_web_secure" {
  type              = "ingress"
  security_group_id = aws_security_group.web_secure_private.id

  from_port   = 443
  to_port     = 443
  protocol    = "TCP"
  cidr_blocks = ["10.0.1.0/24"]
}

resource "aws_security_group" "mysql_private" {
  name   = "mysql_priv"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_mysql" {
  type              = "ingress"
  security_group_id = aws_security_group.mysql_private.id

  from_port   = 3306
  to_port     = 3306
  protocol    = "TCP"
  cidr_blocks = ["10.0.1.0/24"]
}

resource "aws_security_group" "ssh_priv_private" {
  name   = "ssh_priv"
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "allow_ssh_priv" {
  type              = "ingress"
  security_group_id = aws_security_group.ssh_priv_private.id

  from_port   = 22
  to_port     = 22
  protocol    = "TCP"
  cidr_blocks = ["10.0.1.0/24"]
}

### NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "sub01" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sub01.id
  }

  tags = {
    Name = "default"
  }
}
