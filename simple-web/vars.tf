variable "http_port" {
  default     = 8080
  description = "for HTTP requests"
}

variable "ssh_port" {
  default     = 22
  description = "for SSH requests"
}

# replace ssh key on your own
variable "public-key" {
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB6n9K78fB+4HzwqgwLQkd94bawaMdxF6LHqm4eeBWcvVKdE4EJwTGNA6QgfklJevZZFx/BU7xKn0I1iU86Z8Jwmn0dSaohFpcT+ckDoFfugbkQ28nO80rhOZK02m3U/HN7DjJePgLHkpMt6B527DFKrfNvFPZ9h/0EofH/4V2Xj6YFeaomxXtg31hZ7qcKSrI54YmtzFhUau0H6ndr45jVgzTqxYiIk/ioARt/hsmAzglym0/OE2qsGgpf+0gXZo7sLjvuaMhLuM7RqryOqEddqLeZnksJ6hippNUoC9esgJSBWrUSCTRenjurPDtqK2ZN7BS55Z3LG0eOsonJqBB my-email@example.com"
  description = "ssh key for EC2 machines"
}
