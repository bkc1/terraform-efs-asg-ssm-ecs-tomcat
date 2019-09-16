# Terraform launch Tomcat on ECS with SSM and EFS mount

## Overview 
This is a terraform example that launches Tomcat base container image on to an ASG-backed ECS cluster. The bootstrap script installs the SSM agent and mounts the EFS file system to be used for future ambitions. Note that it takes several minutes after Terraform completes for the ECS tasks to run, register with the ALB and become healthy. 

## Prereqs & Dependencies

Create SSH keys in the keys directory

```sh
ssh-keygen -t rsa -f ./keys/mykey -N ""
```


