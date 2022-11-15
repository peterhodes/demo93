#!/usr/bin/bash
# It's true that a tar copy or a git clone would be better - but we're testing and wanted to be a bit more surgical right now.

yum -y update
yum -y install git jq
amazon-linux-extras install ansible2 -y

curl -o /root/.exrc https://raw.githubusercontent.com/peterhodes/demo93/main/root/.exrc

mkdir /root/terraform-download
cd /root/terraform-download
wget https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
unzip terraform*.zip
cp terraform /usr/local/bin
cd -

#git clone git@github.com:peterhodes/demo93.git

cd /root

mkdir /root/terraform
mkdir /root/vpcquery

curl -o /root/doit.bash                  https://raw.githubusercontent.com/peterhodes/demo93/main/root/doit.bash
curl -o /root/doit-peering.py            https://raw.githubusercontent.com/peterhodes/demo93/main/root/doit-peering.py
curl -o /root/doit-createroute           https://raw.githubusercontent.com/peterhodes/demo93/main/root/doit-createroute
curl -o /root/get_hosts                  https://raw.githubusercontent.com/peterhodes/demo93/main/root/get_hosts
curl -o /root/get_vpcs                   https://raw.githubusercontent.com/peterhodes/demo93/main/root/get_vpcs
curl -o /root/get_vpcs.py                https://raw.githubusercontent.com/peterhodes/demo93/main/root/get_vpcs.py
curl -o /root/archived_scripts           https://raw.githubusercontent.com/peterhodes/demo93/main/root/archived_scripts

chmod +x doit.bash doit-peering.py doit-createroute get_hosts get_vpcs get_vpcs.py

curl -o /root/terraform/main.tf          https://raw.githubusercontent.com/peterhodes/demo93/main/root/terraform/main.tf
curl -o /root/vpcquery/json1             https://raw.githubusercontent.com/peterhodes/demo93/main/root/vpcquery/json1
curl -o /root/vpcquery/json2             https://raw.githubusercontent.com/peterhodes/demo93/main/root/vpcquery/json2
curl -o /root/vpcquery/json93            https://raw.githubusercontent.com/peterhodes/demo93/main/root/vpcquery/json93
curl -o /root/vpcquery/l                 https://raw.githubusercontent.com/peterhodes/demo93/main/root/vpcquery/l
