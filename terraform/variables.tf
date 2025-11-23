variable "project_name" {
  type    = string
  default = "n8n"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "root_domain" {
  description = "Root DNS zone in Route 53, e.g. example.com"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for n8n, e.g. n8n -> n8n.example.com"
  type        = string
  default     = "n8n"
}

variable "key_name" {
  description = "Existing EC2 key pair name (for fallback SSH if you ever open port 22)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt registration"
  type        = string
}

variable "db_password" {
  description = "Postgres password for the local n8n DB"
  type        = string
  sensitive   = true
}
