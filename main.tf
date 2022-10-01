provider "aws" {
  region = "eu-central-1"
}

#creating vpc
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MainVPC"
  }
}

#creating public subnet
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

#creating public subnet 2!!!!
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "PublicSubnet2"
  }
}

#creating private subnet
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "private"{
  vpc_id     = aws_vpc.main.id
  cidr_block    = "10.0.3.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "PrivateSubnet"
  }
}

#creating private subnet2!!!!!!!
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "private2"{
  vpc_id     = aws_vpc.main.id
  cidr_block    = "10.0.200.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "PrivateSubnet2"
  }
}

#creating internet gateway
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

#elastic IP for NAT
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on =[aws_internet_gateway.igw]
  
  tags = {
    Name = "NATGatewayEIP"
  }
}

#NAT gateway for VPC
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NATGateway"
  }
}

#route table for public
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

#association publicSubnet to PublicRouteTable
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

}

#route table for public2!!!!!!!!!!!!!!
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

resource "aws_route_table" "public2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable2"
  }
}

#association publicSubnet to PublicRouteTable222222!!!!!!!!!11
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public2.id

}

#route table for private
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

#association privateSubnet to privateRouteTable
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

#route table for private  2!!!!!!!!!!!1
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "PrivateRouteTable2"
  }
}

#association privateSubnet to privateRouteTable
#resources from https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private2.id
}

#creating ec2 instance to private subnet

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  subnet_id	  = "${aws_subnet.private.id}"
  user_data       = <<EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install apache2 -y
  echo "THIS IS WEB SERVER FROM 10.0.3.0 SUBNET" > /var/www/htpd/index.html
  EOF

  tags = {
    Name = "vpcWebServerFromTeraform"
  }
}

resource "aws_instance" "web2" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  subnet_id       = "${aws_subnet.private2.id}"
  user_data       = <<EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install apache2 -y
  echo "THIS IS WEB SERVER FROM 10.0.200.0 SUBNET" > /var/www/htpd/index.html
  EOF

  tags = {
    Name = "vpcSECONDWEBSERVERFROMTeraform"
  }
}

resource "aws_security_group" "TerraformEc2Security" {
  name        = "TerraformEc2Security"
  description = "Allow Inbound Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "hope to work"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraformEc2"
  }
}

#crating load balancer!!!!!!!


resource "aws_elb" "LB" {
  name               = "loadBalancer"
  availability_zones = ["eu-central-1a", "eu-central-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target		= "HTTP:80/"
    interval		= 30
  }


#elastic load balancer attachments!!!!!!!!!!!


  instances                  = ["${aws_instance.web.id}", "${aws_instance.web2.id}"]
  cross_zone_load_balancing  = true
  idle_timeout               = 40

  tags = {
    Name = "Load-Balancer"
  }
}
