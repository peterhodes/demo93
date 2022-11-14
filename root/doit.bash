#!/usr/bin/bash


cd /root/terraform
terraform init  -input=false
terraform apply -input=false -auto-approve
