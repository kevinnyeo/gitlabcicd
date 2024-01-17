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


  












