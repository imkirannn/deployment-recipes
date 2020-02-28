#!/usr/bin/env bash

set -e -o pipefail
rm -f kubernetes.tf versions.tf
export KOPS_RUN_OBSOLETE_VERSION=true
ROOT_PATH1=/home/ubuntu/deployment-recipes
cd ${ROOT_PATH1}/kubernetes-cluster
echo "inside script terraform state bucket name coming as is: ${tf_bucket}"
cd ../terraform 
echo "waiting for backend initalisation...."
sleep 240
terraform init -backend-config=aws-backend.config
TF_OUTPUT=$(terraform output -json)
cd -   
echo $TF_OUTPUT
CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
echo "cluster name: $CLUSTER_NAME"
if [ "$CLUSTER_NAME" == 'null' ];then
	exit 0
fi
STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"

kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > cluster.yaml

kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force

kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i terraform-demo.pub --state ${STATE}

kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
#kops rolling-update cluster ${CLUSTER_NAME} --yes
# kubernetes.tf file  created after kops update cluster  with asg ,elb resources
terraform init
terraform 0.12upgrade -yes
terraform plan
terraform apply -auto-approve


