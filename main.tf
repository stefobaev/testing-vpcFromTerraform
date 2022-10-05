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
  cidr_block = var.cidr_block_public_subnet1
  availability_zone = var.AZone1
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

#creating public subnet 2!!!!
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block_public_subnet2
  availability_zone = var.AZone2

  tags = {
    Name = "PublicSubnet2"
  }
}

#creating private subnet
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "private"{
  vpc_id     = aws_vpc.main.id
  cidr_block    = var.cidr_block_private_subnet1
  availability_zone = var.AZone1

  tags = {
    Name = "PrivateSubnet"
  }
}

#creating private subnet2!!!!!!!
#resources form https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "private2"{
  vpc_id     = aws_vpc.main.id
  cidr_block    = var.cidr_block_private_subnet2
  availability_zone = var.AZone2

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
    cidr_block = var.default_cidr_block
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
    cidr_block = var.default_cidr_block
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
    cidr_block = var.default_cidr_block
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
    cidr_block = var.default_cidr_block
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
  security_groups = [aws_security_group.TerraformEc2Security.id]
  user_data       = <<EOF
  apt -y update
  apt -y install apache2  
  echo "THIS IS WEB SERVER FROM PRIVATE SUBNET" > /var/www/html/index.html
  EOF

  tags = {
    Name = "vpcWebServerFromTeraform"
  }
  depends_on = [
    aws_nat_gateway.nat, aws_internet_gateway.igw
  ]
}

resource "aws_instance" "web2" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  subnet_id       = "${aws_subnet.private2.id}"
  security_groups = [aws_security_group.TerraformEc2Security.id]
  user_data       = "${file("apache_install.sh")}" 

  tags = {
    Name = "vpcSECONDWEBSERVERFROMTeraform"
  }
  depends_on = [
    aws_nat_gateway.nat, aws_internet_gateway.igw
  ]
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = "t2.micro"
  key_name        = var.key_name
  subnet_id       = "${aws_subnet.public.id}"
  security_groups = [aws_security_group.bastion.id]

  tags = {
    Name = "bastion"
  }
}


resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow Inbound Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks	     = [var.default_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.default_cidr_block]
  }

  tags = {
    Name = "bastion"
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

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.bastion.id]
  }

  tags = {
    Name = "terraformEc2"
  }
}

#crating application load balancer!!!!!!!


resource "aws_lb" "LB" {
  name               = "loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TerraformEc2Security.id]
  subnets            = [aws_subnet.private.id, aws_subnet.private2.id]

  tags = {
    Name = "ujs"
  }
}
