variable "cluster_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "AWS tags to be applied to created resources."
}

variable "instance_type" {
  type = string
}

variable "region" {
  type        = string
  description = "The target AWS region for the cluster."
}

variable "publish_strategy" {
  type        = string
  description = <<EOF
The publishing strategy for endpoints like load balancers.

Because of the issue https://github.com/hashicorp/terraform/issues/12570, the consumers cannot use a dynamic list for count
and therefore are force to implicitly assume that the list is of aws_lb_target_group_arns_length - 1, in case there is no api_external. And that's where this variable
helps to decide if the target_group_arns is of length (target_group_arns_length) or (target_group_arns_length - 1)
EOF
}

# variable "lb_target_group_arns" {
#   type = list(string)
# }

# variable "lb_target_group_arns_length" {
#   type = string
# }

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_ipv4_pool" {
  type        = string
  description = "An Public IPv4 Pool"
}

# variable "edge_public_subnet_ids" {
#   type = list(string)
# }

# variable "edge_private_subnet_ids" {
#   type = list(string)
# }

variable "ami_id" {
  type = string
}

variable "user_data_cloudinit" {
  type = string
}

variable "cidr_blocks" {
  type        = list(string)
  description = "A list of IPv4 CIDRs with 0 index being the main CIDR."
}

variable "controllers" {
  type        = list(string)
  description = "A list of Controllers previously created"
}

variable "cloud_user" {
    type = string
}

variable "ssh_private_key" {
    type = string
}

# variable "aap_db_hostname" {
#     type = string
# }

# variable "aap_db_username" {
#     type = string
# }

# variable "aap_db_password" {
#     type = string
# }