resource "aws_vpc" "vpc_handson" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpchandson"
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc_handson.id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public1a"
  }
}
resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.vpc_handson.id
  cidr_block              = "10.0.64.0/18"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public1b"
  }
}
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.vpc_handson.id
  cidr_block        = "10.0.128.0/18"
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "private1a"
  }
}
resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.vpc_handson.id
  cidr_block        = "10.0.192.0/18"
  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "private1b"
  }
}
resource "aws_internet_gateway" "handson_gw" {
  vpc_id = aws_vpc.vpc_handson.id

  tags = {
    Name = "internet_gateway"
  }
}
resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_eip.lb, aws_vpc.vpc_handson]
}
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc_handson.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.handson_gw.id
  }
  tags = {
    Name = "rt_public"
  }
}
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc_handson.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "rt_private"
  }
}
resource "aws_route_table_association" "first_to_public" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "second_to_public" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public_route.id
}
resource "aws_route_table_association" "first_to_private" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "second_to_private" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_route.id
}

data "aws_key_pair" "ssh_key" {
  key_name = "devops6"
}

data "aws_ami" "amazon-linux2023" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_sgrp" {
  name   = "ec2-sgrp"
  vpc_id = aws_vpc.vpc_handson.id

  tags = {
    Name = "ec2_sgrp"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_first" {
  ami                    = data.aws_ami.amazon-linux2023.id
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sgrp.id]
  subnet_id              = aws_subnet.public_1a.id

  user_data = file("user_data.sh")

  tags = {
    Name = "public_first"
  }
}

resource "aws_instance" "public_second" {
  ami                    = data.aws_ami.amazon-linux2023.id
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sgrp.id]
  subnet_id              = aws_subnet.public_1b.id

  user_data = file("user_data.sh")

  tags = {
    Name = "public_second"
  }
}