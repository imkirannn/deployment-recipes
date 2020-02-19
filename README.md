# Deploying Kubernetes clusters with kops and Terraform


## Requirements

* git >= 2.17.1

* terraform >= 0.12.19

### Preliminary Steps:

]$ ROOT_PATH= ~/opt/mywork/Terraform/aws

]$ if [ ! -d "$ROOT_PATH" ];then mkdir -p $ROOT_PATH/kops-tf;fi

]$ git clone https://github.com/imkirannn/deployment-recipes.git $ROOT_PATH/kops-tf/


## Usage

cd $ROOT_PATH/kops-tf/
./kops-deployment.sh -t #creates VPC, bastion host, kops cluster

./kops-deployment.sh -b # to destroy whole newtork

./kops-deployment.sh -p # dry run to see what happens during script


login to baiston host with private key and export kubeconfig with cluster name

let’s say: 

kops state bucket: dev-kops-state-blog

cluster name: k8s-dev.cloudhands.online

]$ export KOPS_STATE_STORE=s3://dev-kops-state-blog && kops export kubecfg  k8s-dev.cloudhands.online

Note: after ]$ are shell commands , need to execute in terminal.


