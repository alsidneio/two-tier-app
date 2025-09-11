resource "aws_vpc" "alsidneio-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "alsidneio-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.alsidneio-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet VM Mongo"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.alsidneio-vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Private Subnet kubernetes cluster"
  }
}


resource "aws_security_group" "allow-ssh" {
  name   = "allow-ssh"
  vpc_id = aws_vpc.alsidneio-vpc.id

  ## allow any device to connect via ssh
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ### Allow instance to talk back to any device 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


## setting up an interface to the internet 
resource "aws_internet_gateway" "exercise-gw" {
  vpc_id = aws_vpc.alsidneio-vpc.id
  tags = {
    Name = "exercise-gw"
  }
}

resource "aws_route_table" "internet-routing" {
  vpc_id = aws_vpc.alsidneio-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.exercise-gw.id
  }

  tags = {
    Name = "gateway route table"
  }
  depends_on = [aws_internet_gateway.exercise-gw]
}

resource "aws_route_table_association" "public_subnet_asso" {
  subnet_id      = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.internet-routing.id
}


