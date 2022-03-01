#!/bin/bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo amazon-linux-extras install epel -y
sudo yum upgrade -y
sudo yum install jenkins java-1.8.0-openjdk-devel -y
sudo yum install git -y
sudo usermod -a -G root jenkins
sudo amazon-linux-extras install docker -y
sudo usermod -a -G docker jenkins
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl start jenkins
sudo systemctl status jenkins