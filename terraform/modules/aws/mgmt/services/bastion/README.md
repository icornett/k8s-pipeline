# Bastion Host

## Variables

- __environmentName__
  - the name of the environment being deployed
  - No default value provided
- __tags__
  - Type: Map
  - Defaults to "Bastion"
- __instance_type__
  - Defaults to t2.micro instance size
- __key_name__
  - the name of the AWS key pair used to authenticate to the system
  - No default value
- __volume_size__
  - The size of the volume attached to the bastion host, smallest available is 50GB
  - Defaults to 50
- __aws_image__
  - The AMI image to deploy for the bastion host
  - Defaults to Amazon Linux NAT image for 11/20/2017: ami-38469440
- __vpc_id__
  - The VPC ID to create the bastion host under
- __fe_subnets__
  - Type: List
  - No default value provided
- __fe_security_groups__
  - Firewall security rule groups for FE
  - No default value provided
- __be_subnets__
  - List of BE subnets to secure for VPC
- __fe_cidr_blocks__
  - List of CIDR blocks for FE

## Resources Created

### Data Sources

- __aws_vpc.selected__
  - Working VPC ID
- __aws_availability_zones.all__
  - Gets the list of availability zones for a given region
- __aws_ssm_parameter.privatekey__
  - Gets the private key created by the `null_resource.keygen`
  - Depends on: Resource `null_resource.keygen`

### Resources

- __aws_route_table.natrt__
  - Create NAT route table
- __aws_route.nat-out__
  - Add NAT as BE gateway
- __null_resource.keygen__
  - Creates AWS Key Pairs if necessary, adds key to local SSH agent and deletes key when destroyed
- __aws_eip.bastion__
  - Create public IP for bastion host
- __aws_instance.bastion__
  - Create NAT instance for administration
- __aws_security_group.natsg__
  - Creates NAT firewall for securing BE resources

#### Rules

- __aws_security_group_rule.SSH-Inbound__
  - Creates SSH ingress rule from FE to BE subnets
- __aws_security_group_rule.all_outbound__
  - Allow all egress traffic on NAT
- __aws_security_group_rule.MySQL-Inbound__
  - Allow FE subnets to query SQL services

#### Scripts

- __manage_keys.py__
  - Create AWS Key Pair or return existing one
  - remove AWS Key Pair on destroy
  - Downloads AWS private key and sets up SSH agent to allow forwarding
    
## Outputs
- __nat_route_table__
  - Outputs the route table created by the bastion host
- __natsg__
  - Outputs the security group rule set applied to NAT
- __bastion_ip__
  - Outputs the IP to connect to the bastion host from the interwebs
- __private_key__
  - Outputs the private key to the state server
  - Sensitive:  This is output to state only, unless recalled expressly