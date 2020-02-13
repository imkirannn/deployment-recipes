#!/bin/bash
ROOT_PATH=/home/ubuntu/deployment-recipes
   cd ${ROOT_PATH}/kops-tf/kubernetes-cluster
   rm -f kubernetes.tf versions.tf
   cd ../terraform && terraform init -backend-config=aws-backed-config
   cd -
   TF_OUTPUT=$(cd ../terraform && terraform output -json)
   CLUSTER_NAME="$(echo ${TF_OUTPUT} | jq -r .kubernetes_cluster_name.value)"
   STATE="s3://$(echo ${TF_OUTPUT} | jq -r .kops_s3_bucket.value)"
   kops toolbox template --name ${CLUSTER_NAME} --values <( echo ${TF_OUTPUT}) --template cluster-template.yaml --format-yaml > cluster.yaml
   kops replace -f cluster.yaml --state ${STATE} --name ${CLUSTER_NAME} --force
   kops create secret --name ${CLUSTER_NAME} sshpublickey admin -i terraform-demo.pub --state ${STATE}
   kops update cluster --target terraform --state ${STATE} --name ${CLUSTER_NAME} --out .
# kubernetes.tf file  created after kops update cluster  with asg ,elb resources
   terraform 0.12upgrade -yes
   terraform init && terraform plan
   terraform apply -auto-approve

