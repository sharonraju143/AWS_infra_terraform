provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "mvpbucket1122"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformstatetable"
  }
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "demo_public_subnet" {
  vpc_id = aws_vpc.demo_vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "demo_IGW" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo_IGW"
  }
}

resource "aws_route_table" "demo_pub_RT" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_IGW.id
  }

}

resource "aws_route_table_association" "demo_rt_assoc" {
  subnet_id      = aws_subnet.demo_public_subnet.id
  route_table_id = aws_route_table.demo_pub_RT.id
}


resource "aws_security_group" "demo_SG" {
  name        = "demo-security-group"
  description = "Allow inbound traffic on ports 80 and 22"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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


resource "aws_instance" "demo_ec2" {
  ami           = "ami-053b0d53c279acc90" 
  instance_type = "t2.micro" 

  tags = {
    Name = "demo_ec2"
  }
  associate_public_ip_address = true
  user_data = <<-EOF
               #!/bin/bash
               apt-get update -y
               apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql
               systemctl start apache2
               systemctl enable apache2
               systemctl start mysql
               systemctl enable mysql
               sudo usermod -a -G www-data $(whoami)
               sudo chown -R $(whoami):www-data /var/www/html
               sudo chmod -R 2775 /var/www/html
               find /var/www/html -type d -exec sudo chmod 2775 {} \;
               find /var/www/html -type f -exec sudo chmod 0664 {} \;
               sudo rm -r /var/www/html/*
               sudo git clone https://github.com/sharonraju143/AWS-Project.git /var/www/html --recursive
               EOF
  key_name              = "azuredevops_mvp"
  vpc_security_group_ids = [aws_security_group.demo_SG.id]
  subnet_id              = aws_subnet.demo_public_subnet.id
}