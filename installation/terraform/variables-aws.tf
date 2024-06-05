variable "custom_endpoints" {
  type = map(string)

  description = <<EOF
(optional) Custom AWS endpoints to override existing services.
Check - https://www.terraform.io/docs/providers/aws/guides/custom-service-endpoints.html

Example: `{ "key" = "value", "foo" = "bar" }`
EOF

  default = {}
}

variable "aws_ami" {
  type = string
  description = "AMI for all nodes.  An encrypted copy of this AMI will be used.  Example: `ami-foobar123`."
}

variable "aws_ami_region" {
  type = string
  description = "Region for the AMI for all nodes.  An encrypted copy of this AMI will be used.  Example: `ami-foobar123`."
}

variable "aws_extra_tags" {
  type = map(string)

  description = <<EOF
(optional) Extra AWS tags to be applied to created resources.

Example: `{ "key" = "value", "foo" = "bar" }`
EOF

  default = {}
}

variable "aws_region" {
  type = string
  description = "The target AWS region for the cluster."
}

variable "aws_vpc" {
  type        = string
  default     = null
  description = "(optional) An existing network (VPC ID) into which the cluster should be installed."
}

variable "aws_public_subnets" {
  type        = list(string)
  default     = null
  description = "(optional) Existing public subnets into which the cluster should be installed."
}

variable "aws_private_subnets" {
  type        = list(string)
  default     = null
  description = "(optional) Existing private subnets into which the cluster should be installed."
}

variable "aws_controller_availability_zones" {
  type = list(string)
  description = "The availability zones in which to create the controllers. The length of this list must match controller_count."
}

variable "aws_public_ipv4_pool" {
  type = string

  description = <<EOF
(optional) Indicates the installation process to use Public IPv4 address
that you bring to your AWS account with BYOIP to create resources which consumes
Elastic IPs when the publish strategy is External.
EOF

  default = ""
}

variable "aws_bootstrap_instance_type" {
  type = string
  description = "Instance type for the controller node(s). Example: `m4.large`."

}

variable "aws_controller_instance_type" {
  type = string
  description = "Instance type for the controller node(s). Example: `m4.large`."

}

variable "aws_controller_root_volume_type" {
  type        = string
  description = "The type of volume for the root block device of controller nodes."
}

variable "aws_controller_root_volume_size" {
  type        = string
  description = "The size of the volume in gigabytes for the root block device of controller nodes."
}

variable "aws_controller_root_volume_iops" {
  type = string

  description = <<EOF
The amount of provisioned IOPS for the root block device of controller nodes.
Ignored if the volume type is not io1.
EOF

}
variable "aws_bootstrap_instance_type" {
  type = string
  description = "Instance type for the controller node(s). Example: `m4.large`."

}
variable "aws_controller_root_volume_encrypted" {
  type = bool

  description = <<EOF
Indicates whether the root EBS volume for controller is encrypted. Encrypted Amazon EBS volumes
may only be attached to machines that support Amazon EBS encryption.
EOF

}

variable "aws_controller_root_volume_kms_key_id" {
  type = string

  description = <<EOF
(optional) Indicates the KMS key that should be used to encrypt the Amazon EBS volume.
If not set and root volume has to be encrypted, the default KMS key for the account will be used.
EOF

  default = ""
}

variable "aws_controller_instance_metadata_authentication" {
  type = string
  default = "optional"
  description = "The session tokens requirement, also referred to as Instance Metadata Service Version 2 (IMDSv2). Values are optional or required. Defaults to optional."
}

variable "aws_controller_security_groups" {
  type = list(string)
  description = "(optional) List of additional security group IDs to attach to the master nodes"
  default = []
}

variable "aws_publish_strategy" {
  type        = string
  description = "The cluster publishing strategy, either Internal or External"
}

variable "rds_engine_version" {
  type        = string
  description = "PostgreSQL version for Ansible Automation"
}

variable "rds_instance_type" {
  type = string
  description = "Instance type for the RDS database node(s). Example: `m4.large`."
}