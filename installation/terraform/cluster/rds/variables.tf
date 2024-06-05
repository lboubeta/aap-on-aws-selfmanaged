variable "cluster_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "AWS tags to be applied to created resources."
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_engine_version" {
  type        = string
  description = "PostgreSQL version for Ansible Automation"
}

variable "aws_bootstrap_instance_type" {
  type = string
  description = "Instance type for the controller node(s). Example: `m4.large`."
}

variable "rds_instance_type" {
  type = string
  description = "Instance type for the RDS database node(s). Example: `m4.large`."
}