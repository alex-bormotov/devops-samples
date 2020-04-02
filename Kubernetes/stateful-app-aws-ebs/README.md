
# StateFul Wordpress App

## Kops

aws s3api create-bucket --bucket alex-cluster-k8s-local --region us-east-1

aws s3api put-bucket-versioning --bucket alex-cluster-k8s-local --versioning-configuration Status=Enabled

### Kops For Linux

set NAME=cluster.k8s.local
set KOPS_STATE_STORE=s3://alex-cluster-k8s-local

kops create cluster --zones us-east-1a ${NAME}--state ${KOPS_STATE_STORE} --yes

kops create secret --name${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops update cluster ${NAME} --yes

kops validate cluster --state ${KOPS_STATE_STORE}

### Kops For Windows

set NAME=cluster.k8s.local
set KOPS_STATE_STORE=s3://alex-cluster-k8s-local

kops create cluster --zones us-east-1a %NAME% --state %KOPS_STATE_STORE% --yes

kops create secret --name %NAME% sshpublickey admin -i ssh/id_rsa.pub

kops update cluster %NAME% --yes

kops validate cluster --state %KOPS_STATE_STORE%

kops get cluster

wait a few minutes...

## Kubectl

kubectl apply -k ./

### Deleting all resources

kubectl delete -k ./

#### Kops For Linux

kops delete cluster ${NAME} --state ${KOPS_STATE_STORE} --yes

delete S3 Bucket, Key Pairs

##### Kops For Windows

kops delete cluster %NAME% --state %KOPS_STATE_STORE% --yes

delete S3 Bucket, Key Pairs
