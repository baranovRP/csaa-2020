variable "availability_zones" {
  type = map
  default = {
    zone1 = "eu-central-1a"
    zone2 = "eu-central-1b"
    zone3 = "eu-central-1c"
  }
}

variable "cidrblocks" {
  type = map
  default = {
    cidrblock_all      = "0.0.0.0/0"
    cidrblock_all_ipv6 = "::/0"
    cidrblock_subnet1  = "10.0.1.0/24"
    cidrblock_vpc      = "10.0.0.0/16"
  }
}
