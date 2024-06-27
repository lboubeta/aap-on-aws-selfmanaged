aws_region = "us-east-1"
# aws_region = "eu-west-1"
# aws_vpc             = ""
# aws_public_subnets  = ""
# aws_private_subnets = ""


cluster_id     = "aap-cwp28"
base_domain    = "sandbox2054.opentlc.com"
cluster_domain = "aap.sandbox2054.opentlc.com"
cloud_user     = "ec2-user"

# us-east-1
aws_ami = "ami-0a5a6e20d546167d4"
aws_ami_region = "us-east-1"

# eu-west-1
# aws_ami = "ami-09ea026fd98022752"
# aws_ami_region = "eu-west-1"

aws_extra_tags = { "key" = "value", "foo" = "bar" }
# aws_public_ipv4_pool
aws_publish_strategy = "External"
v4_cidrs = [ "10.0.0.0/16" ]

aws_bootstrap_instance_type = "m7i.xlarge"

controller_count = 3

aws_controller_instance_type = "m7i.xlarge"
aws_controller_availability_zones = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
# aws_controller_availability_zones = [ "eu-west-1a", "eu-west-1b", "eu-west-1c" ]
aws_controller_root_volume_type = "gp3"
aws_controller_root_volume_size = "100"
aws_controller_root_volume_iops = "3000"
aws_controller_root_volume_encrypted = false
# aws_controller_root_volume_kms_key_id = ""
# aws_controller_instance_metadata_authentication = ""
# aws_controller_security_groups = []

cloudinit = <<EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa ...
  - ssh-rsa ...
EOF

ssh_private_key = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
EOF

# See https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html-single/red_hat_ansible_automation_platform_installation_guide/index#ref-postgresql-requirements
rds_engine_version            = "13"
# See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
rds_instance_type             = "db.m7g.xlarge"
rds_instance_volume_type      = "gp2"
rds_instance_volume_size      = "100"
rds_instance_volume_iops      = "0"
rds_instance_volume_encrypted = false

rds_username = "awx"
rds_password = "changeme"
