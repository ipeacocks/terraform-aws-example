variable "region" {
  default = "us-east-1"
}

variable "ami-image" {
  type = map(any)

  # Ubuntu 16.04
  default = {
    us-east-1      = "ami-a4dc46db" # Virginia
    eu-central-1   = "ami-c7e0c82c" # Frankfurt
    ap-southeast-1 = "ami-81cefcfd" # Singapore
  }

  description = "only 3 regions (Virginia, Frankfurt, Singapore) to show the map feature"
}

variable "credentials" {
  default     = ["~/.aws/credentials"]
  description = "where your access and secret_key are stored, you create the file when you run the aws config"
}

variable "vpc-cidr" {
  default     = "172.28.0.0/16"
  description = "vpc cidr"
}

variable "subnet-public-cidr" {
  default     = "172.28.0.0/24"
  description = "cidr of the public subnet"
}

variable "subnet-private-cidr" {
  default     = "172.28.3.0/24"
  description = "cidr of the private subnet"
}

# replace it on your own
variable "public-key" {
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB6n9K78fB+4HzwqgwLQkd94bawaMdxF6LHqm4eeBWcvVKdE4EJwTGNA6QgfklJevZZFx/BU7xKn0I1iU86Z8Jwmn0dSaohFpcT+ckDoFfugbkQ28nO80rhOZK02m3U/HN7DjJePgLHkpMt6B527DFKrfNvFPZ9h/0EofH/4V2Xj6YFeaomxXtg31hZ7qcKSrI54YmtzFhUau0H6ndr45jVgzTqxYiIk/ioARt/hsmAzglym0/OE2qsGgpf+0gXZo7sLjvuaMhLuM7RqryOqEddqLeZnksJ6hippNUoC9esgJSBWrUSCTRenjurPDtqK2ZN7BS55Z3LG0eOsonJqBB my-email@example.com"
  description = "ssh key to use in the EC2 machines"
}

variable "dns-zone-name" {
  default     = "ipeacocks.internal"
  description = "internal dns name"
}
