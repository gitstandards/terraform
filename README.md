# Terraform AWS EC2 Instance Setup.

This repository contains two examples of creating AWS EC2 instances using Terraform. One example creates an instance without an SSH key pair, while the other sets up an instance with an SSH key pair for secure access.

## Menu
- [Common Configuration](#common-configuration)
- [Folder Structure](#folder-structure)
- [Scenarios](#scenarios)
  - [1. EC2 Instance Without SSH Key Pair](#1-ec2-instance-without-ssh-key-pair)
  - [2. EC2 Instance With SSH Key Pair](#2-ec2-instance-with-ssh-key-pair)
- [How to Create SSH Keys](#how-to-create-ssh-keys)
- [Notes for Students](#notes-for-students)
  - [When to Use Each Scenario](#when-to-use-each-scenario)
  - [Best Practices](#best-practices)
- [Commands to Apply Configuration](#commands-to-apply-configuration)
- [Cleanup](#cleanup)
- [Terraform Cheatsheet](#terraform-cheatsheet)

## Common Configuration

Both examples share some common configuration blocks for Terraform setup and AWS provider. These are detailed below:

1. **Terraform Block**: Specifies the required provider and version.
    ```hcl
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }
    ```

2. **Provider Block**: Configures the AWS provider with the desired region.
    ```hcl
    provider "aws" {
      region = "us-east-1"
    }
    ```

These blocks are consistent across both examples and should be placed at the top of your Terraform configuration file.

## Folder Structure

```
.
├── ec2-without-keys
│   └── ec2_without_keys.tf
├── ec2
│   └── ec2_with_keys.tf
```

## Scenarios

### 1. EC2 Instance Without SSH Key Pair

**File**: `ec2-without-keys/ec2_without_keys.tf`

This scenario creates an EC2 instance without an SSH key pair, which means you cannot directly SSH into the instance. It is useful for instances managed by other tools or used as part of an autoscaling group where no direct access is required.

#### Explanation of Configuration

1. **Resource Block**: Creates an EC2 instance with a specific AMI and instance type.
    ```hcl
    resource "aws_instance" "web" {
      ami           = "ami-0ac4dfaf1c5c0cce9" # Amazon Linux - us-east-1
      instance_type = "t2.micro"
    }
    ```

#### Pros
- Simpler configuration as no SSH key management is required.

#### Cons
- No direct SSH access to the instance.
- Debugging and troubleshooting can be challenging without access.

### 2. EC2 Instance With SSH Key Pair

**File**: `ec2/ec2_with_keys.tf`

This scenario creates an EC2 instance with an SSH key pair, allowing secure access to the instance. It also includes a security group to allow SSH traffic.

#### Explanation of Configuration

1. **Key Pair Resource**: Specifies the public key file for SSH access.
    ```hcl
    resource "aws_key_pair" "my_key" {
      key_name   = "my-key"
      public_key = file("~/.ssh/id_rsa.pub")
    }
    ```

2. **Security Group Resource**: Configures security group to allow SSH traffic.
    ```hcl
    resource "aws_security_group" "allow_ssh" {
      name        = "allow_ssh"
      description = "Allow SSH inbound traffic"

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
    ```

3. **EC2 Instance Resource**: Links the key pair and security group.
    ```hcl
    resource "aws_instance" "web" {
      ami             = "ami-0ac4dfaf1c5c0cce9" # Amazon Linux - us-east-1
      instance_type   = "t2.micro"
      key_name        = aws_key_pair.my_key.key_name
      security_groups = [aws_security_group.allow_ssh.name]

      tags = {
        Name = "devops"
      }
    }
    ```

#### Pros
- Secure access to the instance via SSH.
- Easier debugging and troubleshooting.
- Allows interactive management of the instance if needed.

#### Cons
- Requires management of SSH keys (ensure keys are secure and not lost).

## How to Create SSH Keys

1. Open a terminal on your local machine.
2. Generate an SSH key pair using the following command:
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
   ```
3. Follow the prompts to set a passphrase or leave it empty for no passphrase.
4. The public key will be saved in `~/.ssh/id_rsa.pub`. Use this file in the Terraform configuration.

## Notes for Students

### When to Use Each Scenario
- **Without SSH Key Pair**: Use this for instances in autoscaling groups, ephemeral workloads, or fully managed setups where direct access is unnecessary.
- **With SSH Key Pair**: Use this for development, testing, or any scenario where you need direct access to the instance.

### Best Practices
- Always keep your SSH private keys secure and backed up.
- Restrict SSH access in the security group to trusted IP ranges instead of allowing access from `0.0.0.0/0`.
- Use IAM roles for accessing AWS resources from the instance instead of embedding credentials.

## Commands to Apply Configuration

1. Navigate to the desired scenario folder:
   ```bash
   cd ec2-without-keys # or cd ec2
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the infrastructure:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. (Optional) SSH into the instance if you used the "with SSH key" configuration:
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@<INSTANCE_PUBLIC_IP>
   ```

## Cleanup

To destroy the resources created by Terraform:
```bash
terraform destroy
```

## Terraform Cheatsheet

Here are some commonly used Terraform commands:

- **Initialize Terraform**:
  ```bash
  terraform init
  ```
- **Check the plan before applying**:
  ```bash
  terraform plan
  ```
- **Apply the configuration**:
  ```bash
  terraform apply
  ```
- **Destroy infrastructure**:
  ```bash
  terraform destroy
  ```
- **Format code**:
  ```bash
  terraform fmt
  ```
- **Validate configuration**:
  ```bash
  terraform validate
  ```
- **Show resource state**:
  ```bash
  terraform show
  ```
- **List workspace**:
  ```bash
  terraform workspace list
  ```
- **Switch workspace**:
  ```bash
  terraform workspace select <workspace_name>
  ```
