#!/bin/bash
### PRE REQUISTES: Terraform 0.12 or >
###  		   git client
###		   Access to deployment-recipes github	
set -e -o pipefail
dry_run=0
#ROOT_PATH=/tmp/var/mywork/Terraform/aws
ROOT_PATH=/opt/mywork/Terraform/aws

echo "What's your S3 bucket name for Terraform backend state:::"
echo " "
read tf_bucket
tf_bucket=${tf_bucket:-tf-state-kops-dump}
echo ""
echo "What's your KOPS domain name, created in ROUTE53:::"
echo ""
read cluster_name
cluster_name=${cluster_name:-k8s-dev.cloudhands.online}
echo ""
#echo "$tf_bucket is"
cd $ROOT_PATH/kops-tf
sed -i "s/d_k8s_cl/${cluster_name}/g" terraform/s3-backend/variables.tf
sed -i "s/d_s3_bucket/${tf_bucket}/g" terraform/s3-backend/variables.tf
sed -i "s/d_k8s_cl/${cluster_name}/g" terraform/variables.tf
sed -i "s/d_s3_bucket/${tf_bucket}/g" terraform/variables.tf
sed -i "s/d_s3_bucket/${tf_bucket}/g" terraform/aws-backend.config
cd -
#sed -i "s/\(bucket = \).*\$/\1${S3_BUCKET}/" terraform/aws-backend.config
#sed -i "s/\(bucket = \).*\$/\1${s3_bucket}/" terraform/s3-backend/s3.tf

#sed -i "s/\(kubernetes_cluster_name = \).*\$/\1${cluster_name}/" terraform/s3-backend/s3.tf 
#sed -i "s/\(kubernetes_cluster_name = \).*\$/\1${cluster_name}/" terraform/main.tf
export KOPS_RUN_OBSOLETE_VERSION=true

#if [ ! -d "$ROOT_PATH" ];then
#       mkdir -p $ROOT_PATH/kops-tf
#fi;
#       git clone https://github.com/imkirannn/deployment-recipes.git $ROOT_PATH/kops-tf/

create_s3_bucket () {
   cd ${ROOT_PATH}/kops-tf/terraform/s3-backend/
   terraform init && terraform plan -var="kubernetes_cluster_name=$cluster_name" -var="s3_bucket=$tf_bucket" 
   terraform apply -auto-approve 
}	

check_s3_bucket (){
   if aws s3api head-bucket --bucket "$tf_bucket" 2>/dev/null; then 
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "S3 bucket $tf_bucket exists....";
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   else 
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "Seems First time setup in your environment,So creating to preserve state bucket......"
	create_s3_bucket 
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   fi
}

create_base_nw () {
   cd ${ROOT_PATH}/kops-tf/terraform/
   terraform init -backend-config=aws-backend.config && terraform plan -var="kubernetes_cluster_name=$cluster_name" -var="s3_bucket=$tf_bucket"
   echo  "**************************************************************"
   echo  "Applying config to create VPC, SUBNETS, IGW, NAT ,Rtables"
   echo "**************************************************************"
   terraform apply -auto-approve
}
nw_destroy () {
	UPDATE_SUCCESS=false
  	NUM_TRIES=0
	NUM_RETRIES=5
	cd ${ROOT_PATH}/kops-tf/terraform/
  	while [[ "$NUM_TRIES" -lt $NUM_RETRIES && "$UPDATE_SUCCESS" == "false" ]]; do
		echo "**************************************************************"
        	echo  "Deleting VPC, SUBNETS, IGW, NAT ,Rtables etc................"
		terraform init -backend-config=aws-backend.config
    		terraform destroy -input=false -auto-approve
    		if [ "$?" -eq 0 ]; then
        	    UPDATE_SUCCESS=true
    		fi
		echo "**************************************************************"
    	NUM_TRIES=$((NUM_TRIES+1))
 	done
  	if [ $NUM_TRIES -eq ${NUM_RETRIES} ]; then
      		exit 1
  	fi
	cd s3-backend/
	echo  "**************************************************************"
	echo  "Deleting S3 bucket $S3_BUCKET................"
	echo  "**************************************************************"
	terraform destroy -input=false -auto-approve
        echo "Deleted S3 $S3_BUCKET successfully"
}
#function create_bastion () {
#   cd ${ROOT_PATH}/kops-tf/terraform/app
#   terraform init  && terraform plan
#   terraform apply -auto-approve
#}

####
# Main Starts from here
####
while getopts "ptbd" opt; do
    case "$opt" in
        p) dry_run=1 
		echo "setting dry_run to 1"
		;;
	t) check_s3_bucket
	   create_base_nw
	  # create_bastion
		;;
	b) nw_destroy
		;;
	d) check_s3_bucket
		;;
        ?) echo "./$(basename $0) -p for dry run" >&2
	   echo "./$(basename $0) -t to create everything" >&2
	   echo "./$(basename $0) -b to destroy" >&2
      	   exit 1
      ;;
    esac
done
 if [ "$dry_run" -eq 1 ]; then
    set -v
    set -n
fi
