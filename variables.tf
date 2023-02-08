variable "db_password" {
  description = "Password to connect to DB"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Username to connect to DB"
  type        = string
  default     = "maurodatamapperuser"
  sensitive   = true
}

variable "db_name" {
  description = "DB name"
  type        = string
  default     = "maurodatamapper"
}

variable "db_port" {
  default = 5432
}

variable "http_server_port" {
  default = 8082
}

variable "ssh_server_port" {
  default = 22
}

variable "ec2_key_name" {
  description = "SSH Key"
  type        = string
  default     = "MyAwsKey"

}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

variable "ssh_key" {
  description = "existing ssh key"
  type        = string
  default     = "mdm-dev"
}
