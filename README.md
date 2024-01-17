<h1>GitLab CI/CD For Terraform; Managing Infrastructure</h1>

<h2>Description:</h2>

- <b>GitLab CI integration to start build automatically<br>
- <b>Stages in the pipeline include Validate, Plan, Apply, and Destroy<b/>
- <b>Using Terraform to provision AWS EC2, S3 (Stafefile) and Security Groups via Secret Key config in GitLab<b/>
- <b>Installation of Ansible on EC2 using user data<b/>
- <b>Installation of Jenkins via Ansible Playbook<b/>

<h2>Project Architecture</h2>

<p align="center">
 <img src="https://i.imgur.com/Da6qihu.png" height="80%" width="80%" />

<h2>Objectives:</h2>

- <b> Understand how developers automatically check their code to catch errors and release their software without manual work.<b/>

<h2>Languages and Utilities Used:</h2>

- <b>AWS </b>
- <b>GitLab </b>
- <b>Terraform </b>
- <b>Ansible </b>
- <b>Jenkins </b>

<h2>Program Overview:</h2>

We will be using GitLab CI/CD as a system that helps developers automatically check their code to catch errors and, if everything is okay, <br/>
automatically release their software without manual work. It's like having robots that test and deliver your code for you, saving time and reducing errors.<br/>
<br/>
Based on the infrastructure layout, the lab will be broken down into the following sections:<br/>

[Step 1] Creating IAM User <br/> 

[Step 2] GitLab Setup<br/> 

[Step 3] Terraform Files<br/> 

[Step 4] Configuring GitLab Variables<br/> 

[Step 5] Configuring GitLab CICD<br/> 

[Step 5] Gitlab.yml scripting <br/> 

[Step 5] Destroying resources<br/> 

<h2>Program walk-through:</h2>

<p align="center">
<b>[Step 1] Creating AWS IAM User</b> <br/>
  1. Create a new IAM user that will be used in Gitlab.  <br/>
  2. Downlaod the Access and Secret key csv file. <br/>
 <img src="https://i.imgur.com/1liEeNq.png" height="80%" width="80%" /><br/>
 <img src="https://i.imgur.com/A3YW3FI.png" height="80%" width="80%" /><br/>
<br/>

<p align="center">
<b>[Step 2] GitLab Setup</b> <br/>
  1. Create a GitLab account and create a blank project <br/>
 <img src="https://imgur.com/vdMLAzF.png" height="80%" width="80%" /><br/>
<br/>


<p align="center">
<b>[Step 3] Terraform Files</b> <br/>
  1. Create a new repository in GitLab and upload terraform files <br/>
 <img src="https://i.imgur.com/eBnCt0D.png" height="80%" width="80%" /><br/>
<br/>

## main.tf<br/>

Creates our resources in AWS (EC2, security groups) and auto installation of jenkins via shell script install_jenkins.sh
```text
resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080"

#Defines a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}


resource "aws_instance" "web" {
  ami                    = "ami-0c7217cdde317cfec"  #change Ami based on region and aws image type
  instance_type          = "t2.medium" 
  key_name               = "demokp"   #key pair must be created already
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = templatefile("./install_jenkins.sh", {})

  tags = {
    Name = "Jenkins-sonar" #instance name
  }
  root_block_device {
    volume_size = 8
  }
}
```

## provider.tf<br/>

Defines and configures the AWS provider for managing resources on AWS
```text
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"     #change to desired region.
}
```

## backend.tf<br/>

Specifying a backend configuration for storing the Terraform state in existing S3 bucket
```text
terraform {
  backend "s3" {
    bucket = "kevinyyh-testbucket" # Replace with your actual S3 bucket name
    key    = "Gitlab/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## install_jenkins.sh<br/>

We will be cloning an Ansible Playbook Repo from https://github.com/Aj7Ay/ANSIBLE<br/>
This is a shell script that is ran inside main.tf which executes the following tasks: <br/>
1. Updates the package lists
2. Installs the software-properties-common package, which provides the add-apt-repository command used later in the script.
3. Adds the Ansible PPA (Personal Package Archive) to the system, allowing the installation of Ansible
4. Installation of Ansible on the system
5. Installs the Git version control system on the system
6. Creates a directory named "Ansible" and changes the current working directory to it.
7. Cloning a Git repository from the specified URL into the current directory. The repository contains Ansible playbooks and related files.
8. Executes an Ansible playbook named "Jenkins-playbook.yml" with the inventory set to localhost. The playbook is responsible for configuring Jenkins.
```text
#!/bin/bash
exec > >(tee -i /var/log/user-data.log)
exec 2>&1
sudo apt update -y
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo apt install git -y 
mkdir Ansible && cd Ansible
pwd
git clone https://github.com/Aj7Ay/ANSIBLE.git
cd ANSIBLE
ansible-playbook -i localhost Jenkins-playbook.yml
```
















