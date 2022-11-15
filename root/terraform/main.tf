##############################################################################
##############################################################################

variable "aws_profile"   { default = "default" }
variable "aws_region"    { default = "eu-west-2" }
variable "ami_id"        { default = "ami-098828924dc89ea4a" }
variable "instance_type" { default = "t2.micro" }
variable "key_pair"      { default = "keypair22112" }
variable "public_cidr"   { default = "10.1.0.0/16" }
variable "project_name"  { default = "demo93-tf" }
variable "cfn_cidr"      { default = "10.0.0.0/16" }
variable "cfn_vpcid"     { default = "vpc-0fee6fead17f5f027" }

##############################################################################
##############################################################################

provider "aws" {
    profile   = var.aws_profile
    region    = var.aws_region
}

##############################################################################
## VPC

resource "aws_vpc" "my-vpc" {
  cidr_block           = var.public_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name =  "${var.project_name}-vpc"
    project = "demo93"
  }
}

##############################################################################
## SUBNET

resource "aws_subnet" "my-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.public_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name =  "${var.project_name}-subnet"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
# The data block (above) collects the list of availability zones in order that
#  we can select the first one for the resource block.
# It's also interesting to note that even though the availability zone value
#  is required before creation of the aws_subnet resource, we are able to
#  specify these blocks out of order because terraform parses these blocks and
#  creates a directed dependency graph.
# We could have gone without this step altogether and allow the aws_subnet
#  resource to select an AZ itself, but doing it this way allows us to observe
#  this behaviour.

##############################################################################
## SECURITY GROUP

resource "aws_security_group" "my-sg" {
  name        = "test01"
  description = "test02"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    description      = "SSH inbound"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "22"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name =  "${var.project_name}-sg"
  }
}

##############################################################################
## IGW

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name =  "${var.project_name}-igw"
  }
}

##############################################################################
## VPC GATEWAY ATTACHMENT

# If you look at the official documentation you will see that the Internet
# Gateway resource requires you to specify the VPC ID. Terraform doesn't
# support creating internet gateways without immediately attaching them to a VPC.
#
# Good article here.
# https://stackoverflow.com/questions/67423726/attaching-an-aws-vpc-to-an-igw-with-terraform

##############################################################################
## ROUTE

resource "aws_route" "my-route01" {
  route_table_id            = aws_vpc.my-vpc.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.my-igw.id
}
resource "aws_route" "my-route02" {
  route_table_id            = aws_vpc.my-vpc.main_route_table_id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.my-pcx.id
}

# Note that it is currently unsupported to use both the "aws_route" and "aws_route_table" terraform resources.
#  hence - we cannot use here the aws_route resource and that does cause a small problem in that the route_table
#  that terraform generates does not afford us the opportunity to add the TAGS that we otherwise would.

##############################################################################
## ROUTE TABLE ASSOCIATION

resource "aws_route_table_association" "my-rta" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_vpc.my-vpc.main_route_table_id
}

##############################################################################
## VPC PEERING CONNECTION

resource "aws_vpc_peering_connection" "my-pcx" {
  vpc_id      = aws_vpc.my-vpc.id
  peer_vpc_id = var.cfn_vpcid
  auto_accept = true
  tags = {
    Name =  "${var.project_name}-pcx"
  }
}

# We are effectively connecting to VPCs - the "Cloudformation VPC" (10.0.0.0/16) and
#  the "Terraform VPC" (10.1.0.0/16). We add the appropriate route-table entry for
#  TFM->CFN but we don't have the opportunity (here) to add the route-table entry for
#  CFN->TFM, so we have to do that manually in a script I call doit-createroute

##############################################################################
## INSTANCE

resource "aws_instance" "my-instance" {
  count                       = 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair
  subnet_id                   = aws_subnet.my-subnet.id
  vpc_security_group_ids      = [aws_security_group.my-sg.id]
  associate_public_ip_address = false
  tags = {
    Name =  "${var.project_name}-ec2"
  }
}

##############################################################################
## OUTPUTS

#output "example-ip"  { value = aws_instance.my-instance.public_ip }
#output "example-dns" { value = aws_instance.my-instance.public_dns }
#output "example-az"  { value = aws_subnet.my-subnet.availability_zone }
