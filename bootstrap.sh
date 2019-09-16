#! /bin/bash

set -ex

sleep 5

#Join the default ECS cluster
echo ECS_CLUSTER=myapp >> /etc/ecs/ecs.config
PATH=$PATH:/usr/local/bin
#Instance should be added to an security group that allows HTTP outbound
yum -y update
yum -y install jq bind-utils amazon-efs-utils
#Install NFS client
if ! rpm -qa | grep -qw nfs-utils; then
    yum -y install nfs-utils
fi
#Install pip
yum -y install python-pip
#Install awscli
pip install awscli
#Install SSM
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl status amazon-ssm-agent
#Add support for EFS to the CLI configuration
aws configure set preview.efs true
#Get region of EC2 from instance metadata
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
#Create mount point
mkdir /mnt/efs
#Get EFS FileSystemID attribute
#Instance needs to be added to a EC2 role that give the instance at least read access to EFS
EFS_FILE_SYSTEM_ID=`/usr/bin/aws efs describe-file-systems --region $EC2_REGION | jq '.FileSystems[]' | jq -r '.FileSystemId'`
#Check to see if the variable is set. If not, then exit.
if [ -z "$EFS_FILE_SYSTEM_ID" ]; then
	echo "ERROR: variable not set" 1> /etc/efssetup.log
	exit
fi

#Instance needs to be a member of security group that allows 2049 inbound/outbound
#The security group that the instance belongs to has to be added to EFS file system configuration
#Create variables for source and target

DIR_SRC=$EFS_FILE_SYSTEM_ID.efs.$EC2_REGION.amazonaws.com
DIR_TGT=/mnt/efs 


#Mount EFS file system
mount -t efs $EFS_FILE_SYSTEM_ID $DIR_TGT
