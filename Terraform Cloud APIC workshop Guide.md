# TERRAFORM-CloudAPIC WORKSHOP

### Go to the terminal and run: 

	docker run -it --entrypoint /bin/bash devarshishah3/terraformwkshp:capiclatest
	cd $GOPATH/src/github.com/ciscoecosystem/terraform-provider-aci/clus-capic
	

### What does this docker container have: 
1.	Alpine distribution of Linux with Terraform binary installed 
2.	ACI terraform provider and ACI Go client installed and built

		git clone  -b capic https://github.com/ciscoecosystem/terraform-provider-aci.git
		git clone  -b capic https://github.com/ciscoecosystem/aci-go-client.git
		apk add --no-cache build-base
		cd $GOPATH/src/github.com/ciscoecosystem/terraform-provider-aci
		make build


3. Terraform-ACI examples 


###	Terraform Syntax
	### This is the authentication for ACI Provider
	provider "aci" {
  		username = ""
  		password = ""
  		url      = ""
  		insecure = true
	}
	variable "tenant" {
  		description = "Terraform tenant" #tenant name here
	}
	/*
		Some generic comment
	*/
	resource "aci_tenant" "terraform_ten" {
		name = "terraform_tenant"
  		description = "${var.tenant}"
	}

###	Credentials
	APIC: https://52.52.20.121

	username: lab-user-{usernumber}

	password: CiscoLive2019

replace {usernumber} with the number assigned to your workstation
eg: user1 will be "lab-user-1", user2 will be "lab-user-2"  and so on

<strong>Note: Make sure you are connected to Cisco Network by checking your AnyConnect VPN Client </strong>


# LAB

	1. Create a Tenant
		2. Create a VRF
		3. Create a Cloud Profile
		4. Create Filters and Filter Entries
		5. Create a Contract, Contract Subject and form a relationship to the filters
		6. Create an Cloud App
			7. Create 2 cloud EPGs with selectors
			8. Create an external EPG with selector
		9.  Create a Cloud Context Profile
			10. Create a CIDR
			11. Create a Subnet and add it to an Availability Zone
		12. Create an output to be consumed by AWS.tf 





### Variables

All variables are defined in <em>variables.tf</em>



### Task 0:

Use Your favourite editor to create a file main.tf

Initialize the provider.

	provider "aci" {
  	    username = "lab-user-{usernumber}" #input user number
  	    url      = "https://52.52.20.121"
  	    insecure = true
	    private_key = "admin-509.key"
            cert_name   = "admin-509-cert"
	}

### Task 1:
#### Create a Tenant
A Tenant is a container for all network, security, troubleshooting and L4 – 7 service policies.   Tenant resources are isolated from each other, allowing management by different administrators. 

Edit <em>variables.tf</em>

	variable "tenant_name" {
  		default = "DEV-lab-1334" 
	}
Continue editing <em>main.tf</em>

	resource "aci_tenant" "terraform_ten" {
  		name = "${var.tenant_name}"
	} 

Lets run Terraform:

You need to initialize terraform so it makes sure all the correct resources are avaialble. If the resource is not available, Terraform will download it.

	terraform init 

You should see 

	Terraform has been successfully initialized!

Terraform plan is used for change management and to let the user know what will be configured

	terraform plan -parallelism=1
	
You should see 

	Plan: 1 to add, 0 to change, 0 to destroy.
	
Terraform apply pushes the changes down to the service/device

	terraform apply -parallelism=1	

You will see a list of all the resources which are to be created, modified or destroyed

Please enter <strong>yes</strong>

Once terraform apply is successfully complete you will see a new file in the directory

	terraform.tfstate
	
This is the state file that terraform uses on the subsequent plan and apply.

<strong>Please DO NOT modify this FILE</strong>
	
Now you have a hang of it. Let's march on

### Task 2:
#### Create a VRF
Private networks (also called VRFs or contexts) are defined within a tenant to allow isolated and potentially overlapping IP address space

VRF is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

Continue editing <em>main.tf</em>

	resource "aci_vrf" "vrf1" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "vrf-{usernumber}"#input your usernumber
	}
On the console
	
	terraform plan -parallelism=1
and then on success

	terraform apply -parallelism=1
	
### Task 3:
#### Create a Cloud Provider:
Each user tenant need to have exactly one cloud provider which corresponds to a User account on AWS

Cloud Provider is the AWS account which corresponds to a user tenant.


	#resource "aci_cloud_aws_provider" "cloud_apic_provider" {                       
	#  name              = "aws"                                                                         
	#  tenant_dn         = "${aci_tenant.terraform_ten.id}"                          
	#  access_key_id     = "Your access key id"                                                        
	#  secret_access_key = "your secret access key"                                    
	#  account_id        = "your aws account"                                                                
	#  is_trusted        = "no"                                                                          
	#}


	
### Task 4:
#### Create a Filter
A filter classifies a collection of network packet  attributes

Filter is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

Create 2 filters. One related to ICMP and the second related to https

	resource "aci_filter" "allow_https" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "allow_https-{usernumber}" #input usernumber   
	}
	resource "aci_filter" "allow_icmp" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "allow_icmp-{usernumber}" #input usernumber   
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	

#### Create a Filter entry
Filter entry is a network packet  attributes. It selects a packets based on the attributes specified.

Create a filter entry for https and icmp

Filter Entry is a child object of a Filter. You will have to pass the Filter's (parents) DN (Distinguished Name)

	resource "aci_filter_entry" "https" {
  		name        = "https-{usernumber}" #input usernumber   
  		filter_dn   = "${aci_filter.allow_https.id}"
  		ether_t     = "ip"
  		prot        = "tcp"
  		d_from_port = "https"
  		d_to_port   = "https"
  		stateful    = "yes"
	}

		resource "aci_filter_entry" "icmp" {
  		name        = "icmp-{usernumber}" #input usernumber   
  		filter_dn   = "${aci_filter.allow_icmp.id}"
  		ether_t     = "ip"
  		prot        = "icmp"
  		stateful    = "yes"
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

### Task 5:
#### Create a Contact
Contract is a set of rules governing communication between EndPoint Groups

Contract is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

	resource "aci_contract" "contract_epg1_epg2" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "Web-{usernumber}" #input usernumber   
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	

#### Create a Contact Subject
Contract Subject sets the Permit/Deny, Qos policies of the Contract. Relationship needs to be created from the subject contract to filter entry.

Contract Subject is a child object of a Contract. You will have to pass the Contract's (parents) DN (Distinguished Name)
  
  	resource "aci_contract_subject" "Web_subject1" {
  		contract_dn                  = "${aci_contract.contract_epg1_epg2.id}"
  		name                         = "Subject"
  		relation_vz_rs_subj_filt_att = ["${aci_filter.allow_https.name}","${aci_filter.allow_icmp.name}"]
	}
  
 On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	
### Task 6:
#### Create an Cloud Application Profile

Cloud Application Profile is a collection of end points and contract between them

Cloud Application Profile is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

	resource "aci_cloud_applicationcontainer" "app1" {                                                  
	  tenant_dn = "${aci_tenant.terraform_ten.id}"                                                      
	  name      = "app-{usernumber}"#input your usernumber                                                                               
	} 
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	
### Task 7 and 8:
#### Create 2 End Point Groups(EPGs) and an external EPG. Relate each EPG to a VRF and define an Endpoint selector.

End Points are devices which attach to the network either virtually or physically, 

e.g:
EC2 instance
S3 bucket
etc.

EPG is a logical collection of End Points 

An EPG should be likbed to a VRF.

An EPG must also be linked to a Bridge Domain. End Points of the EPG will be part of this Bridge Domain.

A consumed contract (outbound rule) and a provided contract (inbound rule) must also be added for inter EPG communication 

EPG is a child object of a Cloud Application Profile. You will have to pass the Cloud Application Profiles's (parents) DN (Distinguished Name)


	resource "aci_cloud_e_pg" "cloud_apic_epg1" {                                                        
	  name                             = "epg1-{usernumber}" #input usernumber                                           
	  cloud_applicationcontainer_dn    = "${aci_cloud_applicationcontainer.app1.id}"                    
	  relation_fv_rs_prov              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_fv_rs_cons              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_cloud_rs_cloud_e_pg_ctx = "${aci_vrf.vrf1.name}"                                         
	}

	resource "aci_cloud_endpoint_selector" "cloud_ep_selector1" {                                        
	  cloud_e_pg_dn    = "${aci_cloud_e_pg.cloud_apic_epg1.id}"                                          
	  name             = "devnet-ep1-select-{usernumber}" #input your usernumber                                                           
	  match_expression = "custom:Name=='devwks-{usernumber}-ep1'" #input your usernumber                                             
	}

	resource "aci_cloud_e_pg" "cloud_apic_epg2" {                                                        
	  name                             = "epg2-{usernumber}" #input usernumber                                              	  cloud_applicationcontainer_dn    = "${aci_cloud_applicationcontainer.app1.id}"                    
	  relation_fv_rs_prov              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_fv_rs_cons              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_cloud_rs_cloud_e_pg_ctx = "${aci_vrf.vrf1.name}"                                         
	}

	resource "aci_cloud_endpoint_selector" "cloud_ep_selector2" {                                        
	  cloud_e_pg_dn    = "${aci_cloud_e_pg.cloud_apic_epg2.id}"                                          
	  name             = "devnet-ep2-select-{usernumber}" #input your usernumber                                                             
	  match_expression = "custom:Name=='devwks-{usernumber}-ep2'" #input your usernumber                                             
	}
	
	resource "aci_cloud_external_e_pg" "cloud_epic_ext_epg" {                       
	  cloud_applicationcontainer_dn    = "${aci_cloud_applicationcontainer.app1.id}"                    
	  name                             = "devnet-{usernumber}-inet"   #input usernumber                                         
	  relation_fv_rs_prov              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_fv_rs_cons              = ["${aci_contract.contract_epg1_epg2.name}"]                    
	  relation_cloud_rs_cloud_e_pg_ctx = "${aci_vrf.vrf1.name}"                                         
	}                                                                                                   

	resource "aci_cloud_endpoint_selectorfor_external_e_pgs" "ext_ep_selector" {                        
	  cloud_external_e_pg_dn = "${aci_cloud_external_e_pg.cloud_epic_ext_epg.id}"   
	  name                   = "devnet-ext-{usernumber}" #input userbumber                                                             
	  subnet                 = "0.0.0.0/0"                                                              
	}
  	
 On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

### Task 9:
#### Create a Cloud Context Profile

Cloud Context Profile is a new class in ACI which ties the AWS Regions, CIDRs and Subnets to a VRF

Cloud Context Profile is a child of a Tenant

Cloud Context Profile needs to be associated to a VRF


	resource "aci_cloud_context_profile" "context_profile" {                                            
	  name                     = "devnet-cloud-ctx-profile-3"                                       
	  description              = "context provider created with terraform"                              
	  tenant_dn                = "${aci_tenant.terraform_ten.id}"                                       
	  primary_cidr             = "10.23{usernumber}.231.1/16"  #input usernumber                                                    
	  region                   = "us-west-1"                                                            
	  relation_cloud_rs_to_ctx = "${aci_vrf.vrf1.name}"                                                 
	  depends_on               = ["aci_filter_entry.icmp"]                                              
	} 



On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
  
### Task 10:
#### Create a Cloud CIDR

Create a Cloud CIDR for and attach it to the cloud context profile

	data "aci_cloud_cidr_pool" "prim_cidr" {                                                            
	  cloud_context_profile_dn = "${aci_cloud_context_profile.context_profile.id}"                      
	  addr                     = "10.23{usernumber}.231.1/16" #input usernumber                                                      
	  name                     = "10.23{usernumber}.231.1/16" #input usernumber                                                     
	}

On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1


### Task 11:
#### Create a Cloud Subnet

Create a Cloud Subnet for your ec2 instances. This subnet should be from the CIDR allocated earlier and should be attached to an Availability Zone on AWS

	resource "aci_cloud_subnet" "cloud_apic_subnet" {                                                   
	  cloud_cidr_pool_dn            = "${data.aci_cloud_cidr_pool.prim_cidr.id}"                        
	  name                          = "10.23{usernumber}.231.1/24"  #input usernumber                                               
	  ip                            = "10.23{usernumber}.231.1/24"  #input usernumber                                               
	  relation_cloud_rs_zone_attach = "uni/clouddomp/provp-aws/region-us-west-1/zone-us-west-1a"        
	}

On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1


### Task 12:
#### Create an output

Output information for the ACI created VPC for EC2 instance to consume

	output "demo_vpc_name" {                                                                            
	  value = "context-[${aci_vrf.vrf1.name}]-addr-[${aci_cloud_context_profile.context_profile.primary_cidr}]"
	}

On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

# Output

If all the configuration went through correctly , you are ready to connect the AWS EC2 instances to this topology


# Bonus
- 1. Log into the AWS account and go to the right region 
- 2. Go to Services and check VPC
- 3. Check if the VPC corresponding to cloud APIC's VRF is created. 
- 4. Check if the CIDR,subnet and security group rules related to Cloud APIC are created 
- 5. Copy aws.tf into your terraform working directory
- 5. Enter your account info related to AWS 
- 6. Enter the correct tags matching ep selector
- 6. Run Terraform plan and apply again
- 7. Make sure the EC2 instances are up and use the .pem file provided in the working dir 




# Resources:

Terraform ACI provider: Use branch <strong>master</strong>
<https://github.com/ciscoecosystem/terraform-provider-aci>

ACI Go Client: Use branch <strong>master</strong>
<https://github.com/ciscoecosystem/aci-go-client>




