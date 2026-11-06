# Configure AWS Provider
provider "aws" {
  region = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "makihaji-training-bucket-2026-1101"
  tags = {
    Name = "devops-training-bucket"
  }
}

# Security Group — SSH + HTTP
resource "aws_security_group" "web_sg" {
  name        = "devops-web-sg"
  description = "Allow SSH and HTTP"

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

  tags = {
    Name = "devops-web-sg"
  }
}

# EC2 Server — ready for Ansible
resource "aws_instance" "web_server" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t3.micro"
  key_name      = "Devops-training"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "ansible-managed-server"
  }

  # Prepare server for Ansible
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3 python3-pip
              EOF
}

# Export server details
output "server_public_ip" {
  value = aws_instance.web_server.public_ip
}

