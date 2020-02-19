#!/bin/bash
### PRE REQUISTES: Terraform 0.12 or >
###  		   git client
###		   Access to deployment-recipes github	
set -e -o pipefail
dry_run=0
ROOT_PATH=~/opt/mywork/Terraform/aws
#ROOT_PATH=/opt/mywork/Terraform/aws
S3_BUCKET=tf-state-kops-blog-1
export KOPS_RUN_OBSOLETE_VERSION=true
if [ ! -d "$ROOT_PATH" ];then
       mkdir -p $ROOT_PATH/kops-tf
fi;
#       git clone https://github.com/imkirannn/deployment-recipes.git $ROOT_PATH/kops-tf/

create_s3_bucket () {
   cd ${ROOT_PATH}/kops-tf/terraform/s3-backend/
   terraform init && terraform plan 
   terraform apply -auto-approve
}	

check_s3_bucket (){
   if aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then 
       echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
       echo "S3 bucket $S3_BUCKET exists....";
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
   terraform init -backend-config=aws-backend.config && terraform plan
   echo -n "**************************************************************"
   echo -n "Applying config to create VPC, SUBNETS, IGW, NAT ,Rtables"
   echo -n "**************************************************************"
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
while getopts "ptb" opt; do
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
