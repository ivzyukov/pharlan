variable "access_key" {
  default = "projname:ivzyukov@cloud.croc.ru"
}

variable "secret_key" {
  default = "123123123123"
}

variable "region" {
  default = "croc"
}

provider "aws" {
  endpoints {
    ec2 = "https://api.cloud.croc.ru"
  }

  # NOTE: STS API is not implemented, skip validation
  skip_credentials_validation = true

  # NOTE: IAM API is not implemented, skip validation
  skip_requesting_account_id = true

  # NOTE: Region has different name, skip validation
  skip_region_validation = true

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vol51_vpc" {
  cidr_block = "192.168.0.0/22"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "vol51_subnet" {
  vpc_id                  = "${aws_vpc.vol51_vpc.id}"
  cidr_block              = "192.168.2.0/24"
#  map_public_ip_on_launch = true
}

resource "aws_security_group_rule" "allow_ssh" {
  # NOTE: the only 'ingress' rules is currently supported
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  # NOTE: 'subnet_id' can be specified instead of 'security_groups_id'
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_haproxy_stats" {
  # NOTE: the only 'ingress' rules is currently supported
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  # NOTE: 'subnet_id' can be specified instead of 'security_groups_id'
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_http" {
  # NOTE: the only 'ingress' rules is currently supported
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  # NOTE: 'subnet_id' can be specified instead of 'security_groups_id'
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_https" {
  # NOTE: the only 'ingress' rules is currently supported
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  # NOTE: 'subnet_id' can be specified instead of 'security_groups_id'
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_icmp" {
  # NOTE: the only 'ingress' rules is currently supported
  type        = "ingress"
  from_port   = 1
  to_port     = 1
  cidr_blocks = ["0.0.0.0/0"]
  protocol    = 1
  # NOTE: 'subnet_id' can be specified instead of 'security_groups_id'
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_instance" "lab_web1_vol" {
  ami               = "cmi-0784E547"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-79EDAFAD", "sg-E345A62C" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_web1_vol.id} Description.Value lab_web1_vol"
  }
}

resource "aws_instance" "lab_web2_vol" {
  ami               = "cmi-7DEB5DD5"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C" , "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_web2_vol.id} Description.Value lab_web2_vol"
  }
}

resource "aws_instance" "lab_loadbalancer_vol" {
  ami               = "cmi-9FC10B34"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C", "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_loadbalancer_vol.id} Description.Value lab_loadbalancer_vol"
  }
}

resource "aws_instance" "lab_admin_vol" {
  ami               = "cmi-446C49DE"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C", "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_admin_vol.id} Description.Value lab_admin_vol"
  }
}

resource "aws_instance" "lab_zabbix_vol" {
  ami               = "cmi-6758F831"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C", "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_zabbix_vol.id} Description.Value lab_zabbix_vol"
  }
}

resource "aws_instance" "lab_cachesrv_vol" {
  ami               = "cmi-09030E18"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C", "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_cachesrv_vol.id} Description.Value lab_cachesrv_vol"
  }
}

resource "aws_instance" "lab_db_vol" {
  ami               = "cmi-00FDAAAF"
  key_name	    = "ivzyukov"
  subnet_id         = "${aws_subnet.vol51_subnet.id}"
  instance_type     = "m1.4micro"
  monitoring        = true
  source_dest_check = false
  security_groups   = [ "sg-E345A62C", "sg-79EDAFAD" ]
  availability_zone = "ru-msk-vol51"
  provisioner "local-exec" {
    command = "/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.lab_db_vol.id} Description.Value lab_db_vol"
  }
}
