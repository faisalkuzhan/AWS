# AWS CLI

# References
# https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
# https://awscli.amazonaws.com/v2/documentation/api/latest/index.html  # kullanacagimiz komutlari nasil kullanabiliriz.
# https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/



# Installation

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


# Win:
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


# Mac:
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
# https://graspingtech.com/install-and-configure-aws-cli/


# Linux:
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip  #install "unzip" if not installed
sudo ./aws/install


# Configuration

aws configure

cat .aws/config
cat .aws/credentials

aws configure --profile user1

export AWS_PROFILE=user1  # burada defaultu degistirip user1 yapiyoruz.
export AWS_PROFILE=default # tekrar default kullanicisina geri donuyoruz.

aws configure list-profiles # yuklu profilleri gorebiliyoruz.

aws sts get-caller-identity # komut arayuzu araciligiyla cagrilari hangi account yapti onu gorebiliyoruz.

# IAM
aws iam list-users # iam daki user larimi listeliyor.

aws iam create-user --user-name aws-cli-user #kullanici olusturuyor.

aws iam delete-user --user-name aws-cli-user  #kullanici siliyor.


# S3
aws s3 ls

aws s3 mb s3://guile-cli-bucket #bucket olusturuyor.

aws s3 cp in-class.yaml s3://guile-cli-bucket #in-class.yaml dosyasini s3... bucketina kopyaliyor.

aws s3 ls s3://guile-cli-bucket  #bucketin altindaki dosyalari listeliyor.

aws s3 rm s3://guile-cli-bucket/in-class.yaml #bucket icindeki dosyayi siliyor.

aws s3 rb s3://guile-cli-bucket  #bucket siliyor.


# EC2
aws ec2 describe-instances # bu regiondaki tum instance larimi listeliyor.

aws ec2 run-instances \   # bir tane ec2 ayaga kaldiriyor
   --image-id ami-0022f774911c1d690 \
   --count 1 \
   --instance-type t2.micro \
   --key-name KEY_NAME_HERE # put your key name

aws ec2 describe-instances \  # filtreleme yapiyorum
   --filters "Name = key-name, Values = KEY_NAME_HERE" # put your key name

aws ec2 describe-instances --query "Reservations[].Instances[].PublicIpAddress[]" #cikti kisminda instance larimin ip adresini veriyor.

aws ec2 describe-instances \
   --filters "Name = key-name, Values = KEY_NAME_HERE" --query "Reservations[].Instances[].PublicIpAddress[]" # put your key name

aws ec2 describe-instances \
   --filters "Name = instance-type, Values = t2.micro" --query "Reservations[].Instances[].InstanceId[]"

aws ec2 stop-instances --instance-ids INSTANCE_ID_HERE # put your instance id

aws ec2 terminate-instances --instance-ids INSTANCE_ID_HERE # put your instance id

# Working with the latest Amazon Linux AMI

aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region us-east-1

aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 'Parameters[0].[Value]' --output text

aws ec2 run-instances \
   --image-id $(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query 
'Parameters[0].[Value]' --output text) \
   --count 1 \
   --instance-type t2.micro   # en son surum image id ile bu t2.micro yu run edebiliyorum.

   # Update AWS CLI Version 1 on Amazon Linux (comes default) to Version 2

# Remove AWS CLI Version 1
sudo yum remove awscli -y # pip uninstall awscli/pip3 uninstall awscli might also work depending on the image
# version 2 yi yuklemek icin vesion 1 i yukaridaki kmoutla kaldiriyoruz.


# Install AWS CLI Version 2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip  #install "unzip" if not installed
sudo ./aws/install

# Update the path accordingly if needed
export PATH=$PATH:/usr/local/bin/aws