# CI/CD and Platform Installation for container applications
This repository holds installation of CI/CD pipelines and EKS platforms.  

The requirement is to build container services and deploy the them on an EKS environment. Additionally, whole required infrastructure should be installed by using Terraform.

The infrastructure installation contains three components.
 * Jenkins for building container services
 * EKS on AWS
 * ArgoCD for deployment of services

 ![ci-cd-pipeline](1.png)

## [Jenkins Installation](jenkins-installation)
In the relevant folder you can find all details, in order to install Jenkins on an EC2 server. 
 * providers.tf: AWS connection and modules details
 * security-groups.tf: whole internet connections are allowed for PoC purposes. I could define my internet address but I did not.
 * variables.tf: It keeps EC2 machine type and an existing key name which is used to connect to the EC2 server.
 * vpc.tf: provisions a VPC, subnets, route table, and gateway. In order to get the subnet id which will be created, the different VPC definition was used, compared to the EKS VPC definition.
 * jenkins-ec2.tf: It gets required existing variables from the environment and creates an EC2 server by using the data file.
 * init-script.sh: The required packages is being loaded in the file for running a Jenkins service automatically. 

After checking and updating providers, it is ready to run the following commands to have a Jenkins Server on AWS:
firstly `terraform init` and then `terraform apply`

### Jenkins Configuration
Basicly, firstly the required plugins will be installed, secondly the required users will be created on Jenkins and then create a new MultiBranch Pipeline in order to build docker container by using Jenkinsfile. 

 * `github integration, docker, docker pipeline` need to be installed on jenkins -> manage plugins
 * `Docker Hub and Github users` need to be created on jenkins -> credentials -> system -> global credentials
 * In order to provide **webhook integration**, a token which was created on Github is required to create on jenkins -> credentials -> system -> global credentials
 * In order to open connection for Webhook, github server is required to create on `manage jenkins -> configuration -> add git hub servers`
 
## [EKS Installation](eks-installation)
3 worker nodes in different AZs have been installed by using the Terraform configuration. Generally, [this document](https://learn.hashicorp.com/tutorials/terraform/eks#optional-configure-terraform-kubernetes-provider) is used for the EKS installation. There are small updates in this configuration.
 * providers.tf: AWS connection and modules details
 * vpc.tf: provisions a VPC, subnets and availability zones using the AWS VPC module.
 * security-groups.tf: provisions the security groups used by the EKS cluster.
 * kubernetes.tf: Kubernetes cluster connection details
 * eks-cluster.tf: provisions all the resources (AutoScaling Groups, etc...) required to set up an EKS cluster using the AWS EKS modules. The AutoScaling group configuration contains three nodes in 3 AZs.
 * kubernetes-dashboard-admin.rbac.yaml: It keeps EC2 machine type and an existing key name which is used to connect to the EC2 server.
 * outputs.tf: Outputs the cluster details which will be created.
In order to install an EKS cluster on AWS by using this configuration, firstly run `terraform init` and then `terraform apply`

Finally, the kubeconfig can be configured to connect to the new cluster by running the following command. Since I do not need a Kubernetes dashboard to complete this task, I do not prefer to install Kubernetes dashboard. 

`aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`

## ArgoCD Installation
ArgoCD is used for CD of Kubernetes Deployments. Platform manifest details can be deployed on the EKS cluster by using ArgoCD.

### Install Argo CD

All those components could be installed using a manifest provided by the Argo Project:

`kubectl create namespace argocd`

`kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml`

### Install Argo CD CLI

To interact with the API Server we need to deploy the CLI:

`sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.0.4/argocd-linux-amd64`

`sudo chmod +x /usr/local/bin/argocd`

### Expose argocd-server

A Load Balancer will be used to make it usable ArgoCD:

`kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`

``export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'` ``

### Login and User Details for Web-UI

User details is taken and login with argocd cli if it needs. I wanted to use ArgoCD WebUI.

``export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d` ``

`argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure`

