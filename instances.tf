data "aws_ami" "latest_amzn2_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"]
}

# single web server replaced by auto scalable group
/*
resource "aws_instance" "tf_web_server01" {
  ami           = data.aws_ami.latest_amzn2_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  user_data     = file("user_data.sh")

  security_groups             = [aws_security_group.tf_sg_web_dmz.id]
  subnet_id                   = aws_subnet.tf_subnet1.id
  associate_public_ip_address = true

  tags = {
    Name = "tfWebServer01"
  }
}
*/

data "aws_availability_zones" "available" {
}

resource "aws_launch_configuration" "tf_web_launch_config" {
  image_id      = "ami-076431be05aaf8080"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  user_data     = file("user_data.sh")

  security_groups             = [aws_security_group.tf_sg_web_dmz.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tf_web_server_autoscaling" {
  launch_configuration = aws_launch_configuration.tf_web_launch_config.id
  min_size             = 3
  max_size             = 5
  vpc_zone_identifier  = [aws_subnet.tf_subnet1.id]
  availability_zones   = data.aws_availability_zones.available.names

  tag {
    key                 = "Name"
    value               = "tfWebServer"
    propagate_at_launch = true
  }
}

resource "aws_instance" "tf_db_server01" {
  ami           = data.aws_ami.latest_amzn2_linux.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  security_groups             = [aws_security_group.tf_sg_db.id]
  subnet_id                   = aws_subnet.tf_subnet2.id
  associate_public_ip_address = false

  tags = {
    Name = "tfDBServer01"
  }
}

resource "aws_security_group" "tf_sg_web_dmz" {
  name   = "tfWebDMZ"
  vpc_id = aws_vpc.tf_vpc_environment.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.cidrblocks.cidrblock_all]
    ipv6_cidr_blocks = [var.cidrblocks.cidrblock_all_ipv6]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [var.cidrblocks.cidrblock_all]
    ipv6_cidr_blocks = [var.cidrblocks.cidrblock_all_ipv6]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidrblocks.cidrblock_all]
  }
}

resource "aws_security_group" "tf_sg_db" {
  name   = "tfDBSG"
  vpc_id = aws_vpc.tf_vpc_environment.id

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.cidrblocks.cidrblock_subnet1]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidrblocks.cidrblock_subnet1]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidrblocks.cidrblock_subnet1]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidrblocks.cidrblock_subnet1]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidrblocks.cidrblock_subnet1]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = [var.cidrblocks.cidrblock_all]
    ipv6_cidr_blocks = [var.cidrblocks.cidrblock_all_ipv6]
  }

}
