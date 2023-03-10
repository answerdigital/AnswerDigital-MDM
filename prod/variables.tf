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

variable "domain_http_server_port" {
  default = 80
}

variable "http_protocol" {
  default = "HTTP"
}

variable "ssh_server_port" {
  default = 22
}

variable "container_internal_port" {
  default = 8080
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

variable "mdm_plugins_prod" {
  type  = string
  description = "Plugins required in production environment"
  default = "uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-xsd:1.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-authentication-openid-connect:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-freemarker:2.2.0;uk.ac.ox.softeng.maurodatamapper.plugins:mdm-plugin-sparql:2.2.0"
}

variable "docker_image_url" {
  type = string
  description = "Public Docker Image url from ECR"
  default = "673599754891.dkr.ecr.eu-west-2.amazonaws.com/mdm-docker:prod1.1"
}

variable "ecs_cpu_allocation" {
  default = 2048
}

variable "ecs_memory_allocation" {
  default = 4096
}

variable "mdm_email_from_address" {
  type = string
  description = "mdm email from address"
  default = "nhse-mauro-support@answerdigital.com"
}

variable "mdm_email_server_url" {
  type = string
  description = "mdm email server url"
  default = "email-smtp.eu-west-2.amazonaws.com"
}