<h1>Terraform Infrastructure as Code (IaC) with GitLab CI/CD</h1>

<h2>Description:</h2>

- <b>Implemented a GitLab CI/CD pipeline with distinct stages for validation, planning, application, and destruction of infrastructure.<b/>
- <b>Implemented a validation stage (validate) to ensure the correctness of Terraform configurations before applying changes<b/>
- <b>Utilized the terraform plan command to generate an execution plan and saved it as an artifact (tfplan) for review<b/>
- <b>Implemented a destruction stage (destroy) with manual approval, providing a controlled process for tearing down infrastructure<b/>
- <b>Managed AWS credentials securely within the GitLab CI/CD pipeline, ensuring the protection of sensitive information<b/>
- <b>Dynamically configured the Terraform Docker image (hashicorp/terraform:light) with the required environment settings.<b/>

<h2>Project Architecture</h2>

<p align="center">
 <img src="https://i.imgur.com/Da6qihu.png" height="80%" width="80%" />

<h2>Objectives:</h2>

- <b> Gained hands-on experience in automating infrastructure deployment, validation, and destruction using Terraform in a CI/CD environment.<b/>

<h2>Languages and Utilities Used:</h2>

- <b>AWS </b>
- <b>GitLab CI/CD </b>
- <b>Terraform </b>
- <b>Ansible Playbook Source: https://github.com/Aj7Ay/ANSIBLE</b>

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

[Step 6] Gitlab.yml scripting <br/> 

[Step 7] Destroying resources<br/> 

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
<p align="center">
<b>[Step 4] Configuring GitLab Variables</b> <br/>
  1. Under GitLab CICD Settings, add in AWS Access and Secret keys when creating our IAM user in step 1  <br/>
 <img src="https://i.imgur.com/6pwGi97.png" height="80%" width="80%" /><br/>
<br/>

<p align="center">
<b>[Step 5] Configuring GitLab CICD </b> <br/>
  1. Create a gitlab-ci.yml file and include the following scripts:
<br/>

## stages<br/>
This section defines the stages in the CI/CD pipeline. In your configuration, you have four stages: validate, plan, apply, and destroy. <br/>
```
stages:
  - validate
  - plan
  - apply
  - destroy
```

## image<br/>
Specifies the Docker image to use for the GitLab Runner. In this case, I'm using the "hashicorp/terraform:light" image for running Terraform commands. 
The entrypoint lines set the environment to include commonly used paths. <br/>
```
image:
  name: hashicorp/terraform:light
  entrypoint:
    - '/usr/bin/env'
    - 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
```

## before_script<br/>
This section defines commands to run before each job in the pipeline. <br/>

- The first two lines export the AWS access key and secret access key as environment variables, which are used for AWS authentication in your Terraform configuration.

- rm -rf .terraform: This removes any existing Terraform configuration files and state files to ensure a clean environment.

- terraform --version: Displays the Terraform version for debugging and version confirmation.

- terraform init: Initializes Terraform in the working directory, setting up the environment for Terraform operations.

```
before_script:
  - export AWS_ACCESS_KEY=${AWS_ACCESS_KEY_ID}
  - export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  - rm -rf .terraform
  - terraform --version
  - terraform init
```

## validate
Defines a job named "validate" in the "validate" stage. This job validates the Terraform configuration.<br/>

- script: Specifies the commands to run as part of this job. In this case, it runs terraform validate to check the syntax and structure of your Terraform files.
```
validate:
  stage: validate
  script:
    - terraform validate
```

## plan
This job, in the "plan" stage, creates a Terraform plan. <br/>

- script: Runs terraform plan -out=tfplan, which generates a plan and saves it as "tfplan" in the working directory.

- artifacts: Specifies the artifacts (output files) of this job. In this case, it specifies that the "tfplan" file should be preserved as an artifact.
```
plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan
```

## apply
This job, in the "apply" stage, applies the Terraform plan generated in the previous stage.<br/>

- script: Runs terraform apply -auto-approve tfplan, which applies the changes specified in the "tfplan" file.

- dependencies: Specifies that this job depends on the successful completion of the "plan" job.
```
apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan
```

## destroy 
This job, in the "destroy" stage, is intended for destroying the Terraform-managed resources. <br/>

- script: Runs terraform init to initialize the Terraform environment and then runs terraform destroy -auto-approve to destroy the resources. The -auto-approve flag ensures non-interactive execution.

- when: manual: Specifies that this job should be triggered manually by a user.

- dependencies: Ensures that this job depends on the successful completion of the "apply" job, meaning you can only destroy resources that have been applied by a prior "apply" job.
```
destroy:
  stage: destroy
  script:
    - terraform init
    - terraform destroy -auto-approve
  when: manual
  dependencies: 
    - apply
```
 
## gitlab.yml script
```
stages:
  - validate
  - plan
  - apply
  - destroy

image:
  name: hashicorp/terraform:light
  entrypoint:
    - '/usr/bin/env'
    - 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
before_script:
  - export AWS_ACCESS_KEY=${AWS_ACCESS_KEY_ID}
  - export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  - rm -rf .terraform
  - terraform --version
  - terraform init

validate:
  stage: validate
  script:
    - terraform validate

plan:
  stage: plan
  script:
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - tfplan

apply:
  stage: apply
  script:
    - terraform apply -auto-approve tfplan
  dependencies:
    - plan

destroy:
  stage: destroy
  script:
    - terraform init 
    - terraform destroy -auto-approve
  when: manual
  dependencies: 
    - apply
```
<br/>
<p align="center">
<b>[Step 6] Gitlab.yml scripting</b> <br/>
  1. Create a .gitlab.yml file and in the scripts  <br/>
  2. After committing, it will automatically start the build <br/>
  3. Check pipeline console and AWS console. We can see that our AWS resources has been successfully provisioned. <br/>
  <img src="https://i.imgur.com/spHpPMf.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/K7zJlH3.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/a5bxdVm.png" height="80%" width="80%" /><br/>
<br/>
  4. Connect to EC2 instance. We can see that there is a cloned Ansible directory that was created using our shell script. <br/>
  <img src="https://i.imgur.com/2ElHuBF.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/wrkBPbi.png" height="80%" width="80%" /><br/>
<br/>
  5. To access Jenkins, enter machine public ip via port 8080 <br/>
  Obtain Jenkins password via provided path <br/>
  <img src="https://i.imgur.com/jDMS5uS.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/MeCfch7.png" height="80%" width="80%" /><br/>
<br/>

<p align="center">
<b>[Step 7] Destroy</b> <br/>
  1. Destroy stage can be called in Gitlab pipeline by pressing on the gear icon.  <br/>
  We can see all AWS resources created in the pipeline has been destroyed. <br/>
  <img src="https://i.imgur.com/xtH2wbg.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/fLnQYQ7.png" height="80%" width="80%" /><br/>
  <img src="https://i.imgur.com/fBOqIVP.png" height="80%" width="80%" /><br/>
<br/>
















