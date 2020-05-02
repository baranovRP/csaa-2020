provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "tf_ec2"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpuAHOg5gfSRQhXoarWiPxAodSwrIlKniZfWpstUJmHtGn3eqCC2PvIyJ1LzFvj576KTgqPxno9Fxlp2GYrfjFefFTdVIIWaMnmbir7nXjMXvUeAZjOJsUZw1sFJ8YX6dZ9JB5XjN3mvo763VkPN9eO745A3HHZzzLyCjj1DF3fDUlqKw4eCj3zhp1nrjJ36+fSRg9BSrRJGaUvJc93lORVkUCw4iCsjnwnqRb/Pratd1uw8pS+CH46ZCORJkTUdvJ+DsL46nwrv7Ai4jevZQYhzSX0PwWiXdpEY3qPYfdKf9EDF1lfZRFKthx7x/eKdMobqaEDQ+OysRrPlU7NvBP"
}
