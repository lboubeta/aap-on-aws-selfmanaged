aws_region = "us-east-1"
# aws_region = "eu-west-1"
# aws_vpc             = ""
# aws_public_subnets  = ""
# aws_private_subnets = ""


cluster_id = "12ce1660-21af-11ef-8e59-ba8f72343196"
base_domain = "sandbox2451.opentlc.com"
cluster_domain = "aap-controller.sandbox2451.opentlc.com"

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
aws_controller_root_volume_iops = "0"
aws_controller_root_volume_encrypted = false
# aws_controller_root_volume_kms_key_id = ""
# aws_controller_instance_metadata_authentication = ""
# aws_controller_security_groups = []

cloudinit = <<EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSyclDB6BZBVfrFzP+6KeLAS9aK0BjdnByZ+FpeAuoizugzmz9FDeuUp1+yHFxcKya/nPIGUp4oHFPv8RSCx/kQax2yLCGZX6wMI/6MG3CriDXv0FcXmse8TWO47FQORyP5dKuM8l5ggI3kj5Vo07gFVPDJlC9zUjs2JHgUMkHcw8zmJlA+uzpxZe1eCMV44Z4F11Ek0T7lu+xflHs8X3P5Ez3eouDjb79QKr871hHm8wrXmI2mDM0Vd5JWYlK2aWLGiQlLSmsjW90N0MrosgnyJbT//ZzCRjaQZN2xvo+VKT39AkH1/mLKlKlvcJiYrQZPuAqqa3HZXA55nGm+Z8y9ws0FH61WItQ9VETl30vnvkXQ81U0Wlqs8YlyNDa6Lc9JPt4ii/OUWy0s3K77odDz7cWEUFfLFJq5MUDpOHGaocnJ//thHQxya8/P++5g3bC2GQZl5enl4E/LjApIa3w8AKhyvfcrM1tBl9ezjo7QN+SE4p75aVtaWzwB0G5odk= rgordill@musashi
EOF

# See https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html-single/red_hat_ansible_automation_platform_installation_guide/index#ref-postgresql-requirements
rds_engine_version            = "13"
# See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
rds_instance_type             = "db.m7g.xlarge"
rds_instance_volume_type      = "gp3"
rds_instance_volume_size      = "100"
rds_instance_volume_iops      = "3000"
rds_instance_volume_encrypted = false

rds_username = "ansible"
rds_password = "changeme"