###
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "atlantis"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfObcpiUJAYEGXnJ0FOcyTM6pFvs1tTFKhpuNWfE/sssk7oGnM2Kw3zdktg7Ykq/LV+tOlxl9VtBa9FN6BQmxMi/bW96c47rGYL8VMPCQ3e7Qa7mKjbx1coBcQg9gxaLpWA73oD41O2cHYit084SlS8BTiRl1f4Lc9nPKM9RKyOzC6zajyIBFLDjOcRgVkEVoEW8QYroAFLJwKuKqu9oI9HAuov0c1o99J4ASqKmC/rm/76d1Fhs83dXNhLldmme7aN7M7XKX+8NM7hPeJtG3LGuxOtVMmMOhPkqG7FbtFWhKuXvD5CdU/S7QkxGo3lkZE+cwrUqKWQmEB6t4lKkxB"
}

data "aws_availability_zones" "available" {
  all_availability_zones = true
}

resource "aws_vpc" "acloudguru_vpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "acloudguruVPC"
  }
}

resource "aws_subnet" "acloudguru_sub01" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.acloudguru_vpc.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "10.0.1.0 - ${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_subnet" "acloudguru_sub02" {
  cidr_block           = "10.0.2.0/24"
  vpc_id               = aws_vpc.acloudguru_vpc.id
  availability_zone_id = data.aws_availability_zones.available.zone_ids[1]

  tags = {
    Name = "10.0.1.0 - ${data.aws_availability_zones.available.names[1]}"
  }
}
