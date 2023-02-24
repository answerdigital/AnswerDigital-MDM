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

variable "https_server_port" {
  default = 443
}

variable "http_protocol" {
  default = "HTTP"
}

variable "https_protocol" {
  default = "HTTPS"
}

variable "ssh_server_port" {
  default = 22
}
variable "container_internal_port" {
  default = 8080
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

variable "az_west_a" {
  description = "aws availability zone region 2A"
  type        = string
  default     = "eu-west-2a"
}

variable "az_west_b" {
  description = "aws availability zone region 2B"
  type        = string
  default     = "eu-west-2b"
}

variable "az_west_c" {
  description = "aws availability zone region 2C"
  type        = string
  default     = "eu-west-2c"
}

variable "az_west_two" {
  description = "aws availability zone region 2C"
  type        = string
  default     = "eu-west-2"
}

variable "mdm_authority_name" {
  description = "MDM Authority Name"
  type        = string
  default     = "NHS England developments"
}

variable "mdm_domain_url" {
  description = "MDM Domain Url"
  type        = string
  default     = "https://develop.metadata.nhs.uk"
}

variable "certificate_arn" {
}

variable "service_launch_type" {
  type        = string
  description = "ECS service laucnh type."
  default     = "FARGATE"
}

variable "scheduling_strategy" {
  type        = string
  description = "ECS service scheduling strategy."
  default     = "REPLICA"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "mdm-docker"
}

variable "network_protocol" {
  type        = string
  description = "network protocol type"
  default     = "tcp"
}


variable "mdm_plugins_dev-test" {
  type  = string
  description = "Plugins required in Dev and Test environment"
  default = "uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-artdecor:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-awsglue:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-csv:4.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-digital-object-identifiers:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-excel:5.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-fhir:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-database-sqlserver:8.1.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-database-mysql:7.1.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-database-oracle:6.1.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-database-postgresql:7.1.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-xsd:1.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-profile-dcat:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-profile-schema-org:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-authentication-openid-connect:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-freemarker:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-sparql:2.2.0"
}

variable "mdm_plugins_prod" {
  type  = string
  description = "Plugins required in production environment"
  default = "uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-xsd:1.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-authentication-openid-connect:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-freemarker:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-sparql:2.2.0"
}

variable "docker_image_url" {
  type = string
  description = "Public Docker Image url from ECR"
  default = "public.ecr.aws/r5f6k8o3/mdm-docker:latest"
}