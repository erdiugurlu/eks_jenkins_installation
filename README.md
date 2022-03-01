# CI/CD and Platform Installation for container applications
This repository holds installation of CI/CD pipelines and EKS platforms.  

The requirement is to build container services and deploy the them on an EKS environment. Additionally, whole required infrastructure should be installed by using Terraform.

The infrastructure installation contains three components.
 * Jenkins for building container services
 * EKS on AWS
 * ArgoCD for deployment of services

## [Jenkins Installation](jenkins-installation)
In the relevant folder you can find all details, in order to install Jenkins on an EC2 server. 
 * providers.tf: AWS connection and modules details
 * security-groups.tf: whole internet connections are allowed.
 * variables.tf: It keeps EC2 machine type and an existing key name which is used to connect to the EC2 server.
 * vpc.tf: whole network parts is kept in this file.
 * jenkins-ec2.tf: It gets required existing variables from the environment and creates an EC2 server by using the data file.
 * init-script.sh: The required packages is being loaded in the file for running a Jenkins service automatically. 

After checking and updating providers, it is ready to run the following commands to have a Jenkins Server on AWS.
firstly `terraform init` and then `terraform apply`

## [EKS Installation](eks-installation)
