provider "aws" {
  region = "us-east-1"
}

# HCL code -> HashiCorp Language
resource "aws_key_pair" "keypair" {
  key_name   = "developer"
  public_key = file("~/.ssh/id_rsa_aws.pub") # ssh-keygen -t rsa -b 4096 -C "mymail@id.com"
  # flaw here: I need to share private with my team members
  # if anything happens to my resource (Ec2), blame is on me. log -> private using - BAD PRACTICE
}


# ---> 
# service account (generic mail id) to automate
# generate key pair using tls provider with generic mail id
# share public key with aws_key_pair resource
# issues - No track why (5-10) 

# OK OK PRACTICE -> we in automation.



# resource "tls_private_key" "developer_1" { # Best approach, access to IAM users keys pair
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "local_file" "key_pair" {
#   content  = tls_private_key.developer_1.private_key_pem
#   filename = "~/.ssh/id_rsa_aws_1"
#   file_permission = "400"
  
# }

# Store the keys in a secure vaults -> Conjur, Hashicorp Vault, AWS Secrets Manager
# maintaince of password, keys

# MS Teams -> Groups # Broadcast the private key which is bad practice
# Boradcast if private key needs get from valult under this folder - good practice

# default vpc and sg or what we create is shared amoung team members

resource "aws_security_group" "ec2_sg" { # Good Practice
  name        = "ec2_security_group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = "vpc-0a774115116f788d3"

  ingress { # Inbound rules
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # Outbound rules
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-07ff62358b87c7116"
  instance_type = "t2.micro"
#   key_name = "test" # BAD PRACTICE
#   key_name = "developer"
  key_name = aws_key_pair.keypair.key_name
#   vpc_security_group_ids = ["sg-024ffc400c70be098", "sg-00fb9517f25ff5d57"] # Good Practice
#   security_groups = ["default"] # OK OK PRACTICE (region - permision changes - security issue)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id] # Good Practice

  tags = {
    Name = "WebServerInstance"
    Environment = "Development"
    Project = "TerraformDemo"
    owner = "DevOpsTeam"
    CostCenter = "CC1001"
    abcd = "xyz"
  }
}




## Q: write a code to print even numbers from 1 to 10
