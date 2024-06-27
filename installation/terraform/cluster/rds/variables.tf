variable "cluster_id" {
  type = string
}

variable "cidr_blocks" {
  type        = list(string)
  description = "A list of IPv4 CIDRs with 0 index being the main CIDR."
}

variable "vpc_id" {
  type = string
}

variable "availability_zones" {
  type        = list(string)
  description = "List of the availability zones in which to create the controllers. The length of this list must match instance_count."
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

variable "rds_instance_type" {
  type = string
  description = "Instance type for the RDS database node(s). Example: `m4.large`."
}

variable "rds_instance_volume_type" {
  type        = string
  description = "The type of volume for the root block device of postgres RDS."
}

variable "rds_instance_volume_size" {
  type        = string
  description = "The size of the volume in gigabytes for the root block device of postgres RDS."
}

variable "rds_instance_volume_iops" {
  type = string

  description = <<EOF
The amount of provisioned IOPS for the root block device of postgres RDS.
Ignored if the volume type is not io1.
EOF

}

variable "rds_instance_volume_encrypted" {
  type = bool

  description = <<EOF
Indicates whether the root EBS volume for controller is encrypted. Encrypted Amazon EBS volumes
may only be attached to machines that support Amazon EBS encryption.
EOF

}

variable "rds_skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip the final snapshot on destroy RDS"
}

variable "rds_username" {
  description = "RDS Database instance username"
  type = string
}

variable "rds_password" {
  description = "RDS Database instance password"
  type = string
  sensitive = true
}
