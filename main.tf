provider "aws" {
  region = var.aws_region
}
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
}
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
}
resource "aws_security_group" "my_sg" {
  name   = "allow_http"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "my_instance1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_sg.id]
}
resource "aws_instance" "my_instance2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_sg.id]
}
resource "aws_elb" "my_elb" {
  name               = "my-elb"
  
  //availability_zones = [aws_subnet.my_subnet.availability_zone]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  subnets = [aws_subnet.my_subnet.id]
  instances = [aws_instance.my_instance1.id, aws_instance.my_instance2.id]
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDegF/GvJkpUmSPt3JJX9F8gkergFqB3Iv7R58bxscCycKFV9JbqSmdkEu1ojBk6O+x3SLEiGuDW8KbEB9WuOsLFwce9CtkpLhn4dJj15BDH6pR072qu4u4w7+M5qHp0TkZHXeHyAckASi47pEOKLvdgOYz9AGfxMaIDf0lUJo/Gv5rONICP6k1vNPcAPavqV4J5EnoGRoBLSWKWErF0vEjfSQ82CxYHni9YX+qQNychfAwukJfUWwdbkk6xI/dM6/7PuPf7PkkGhqzo4J2Lf+FwH0NNQ7y8+nU8qSbRCsEQVi3/xOfswFgPDrIoM9ouUK0Iuvzj3Dvbfg/RyfJrLKaCAdFMPBdOv5QxT8H0qOq8rAK29lZeQ0tv34eFbhd0vq/E50eRNfsBazET5RyAR7xFf1rOp2A0DbOSw80tBJBOPhAVIJaVhyCmA14QDMQDz02EAQ1E9DxnaXExE7G2eoZNImLrGsA6W+RFywClfi0TS++d/AW7bCKxNrMHfS1XcM= ec2"
}


