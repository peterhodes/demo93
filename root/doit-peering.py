#!/usr/bin/python3

import os
import re

vpcCmd = "aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`project`]|[?Value==`demo93`]].VpcId' --output text"
print('Running >',vpcCmd,'<',sep='')
vpcString = os.popen(vpcCmd).read()
vpcList   = re.split('\s+',vpcString)
print('VpcIDs >',vpcString,'<',sep='')


peeringCmd = 'aws ec2 create-vpc-peering-connection --vpc-id ' + vpcList[0] + ' --peer-vpc-id ' + vpcList[1] + ' | egrep "VpcPeeringConnectionId"'
print('Running >',peeringCmd,'<',sep='')
peeringString = os.popen(peeringCmd).read()
peeringList   = re.split('\s+',peeringString)


peeringId=peeringList[2]
peeringId=re.sub('[",]', '', peeringId)
print('Peering ID >',peeringId,'<',sep='')


acceptCmd = 'aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id ' + peeringId
print('Running >',acceptCmd,'<',sep='')
acceptString = os.popen(acceptCmd).read()
