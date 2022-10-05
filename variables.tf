variable "key_name" {
  description = "Name of keypair to ssh"
  default     = "frankubuntu"
}

variable "cidr_block" {
  description = "cidir for vpc"
  default     = "10.0.0.0/16"
}

variable "cidr_block_public_subnet1" {
  description = "cidir for public subnet 1"
  default     = "10.0.1.0/24"
}

variable "cidr_block_public_subnet2" {
  description = "cidir for public subnet 2"
  default     = "10.0.100.0/24"
}

variable "cidr_block_private_subnet1" {
  description = "cidir for private subnet 1"
  default     = "10.0.3.0/24"
}

variable "cidr_block_private_subnet2" {
  description = "cidir for private subnet 2"
  default     = "10.0.200.0/24"
}

variable "default_cidr_block" {
  description = "default cidr"
  default     = "0.0.0.0/0"
}

variable "AZone1" {
  description = "availiabillity zone 1 "
  default     = "eu-central-1a"
}

variable "AZone2" {
  description = "availiabillity zone 2"
  default     = "eu-central-1b"
}
