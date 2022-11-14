#!/usr/bin/python3

import subprocess
import json

output = subprocess.run(["aws", "ec2", "describe-vpcs", "--query", "Vpcs[*]"],  stdout=subpr
ocess.PIPE, stderr=subprocess.PIPE)

output_utf8=output.stdout.decode('utf-8')
output_utf8_json = json.loads(output_utf8)
#print(output_utf8_json)

#for key in output_utf8_json:
#     print(key)

print(type(output_utf8))
print(type(output_utf8_json))
