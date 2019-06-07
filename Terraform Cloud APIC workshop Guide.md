# TERRAFORM-ACI WORKSHOP

### Go to the terminal and run: 

	docker run -it --entrypoint /bin/bash devarshishah3/terraformwkshp:capic
	cd $GOPATH/src/github.com/ciscoecosystem/terraform-provider-aci/examples/clus-capic
	

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
- 1. Create a Tenant
	- 2. Create a VRF
	- 3.	Create a Bridge Domain
		- 4. Create a Subnet
	- 5. Create a VMM Domain
	- 6. Create a Filter
		- 7. Create a Filter Entry
	- 8. Create a Contract
		- 9. Create a Contract Subject and form a relationship to the filter  
	- 10.	Create an Application Profile
		- 11.	Create EPGs (2 EPGs). 	Relate each EPG to a VMM Domain, BD create earlier and a Contract.




		 
cd /go/src/github.com/ciscoecosystem/terraform-provider-aci/examples/clus

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
  		default = "DEVWKS-1334" 
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


resource "aci_cloud_aws_provider" "cloud_apic_provider" {                       
  name              = "aws"                                                                         
  tenant_dn         = "${aci_tenant.terraform_ten.id}"                          
  access_key_id     = "AKIAJCLIIUJAQHKPBJOQ"                                                        
  secret_access_key = "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"                                    
  account_id        = "310368696476"                                                                
  is_trusted        = "no"                                                                          
}

On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

### Task 4:
#### Create a Subnet
Subnet is a child object of a BD. You will have to pass the bd's (parents) DN (Distinguished Name)

Edit <em>variables.tf</em>

	variable "bd_subnet" {
  		type    = "string"
  		default = "{usernumber}.{usernumber}.{usernumber}.1/24" #input your usernumber
  		# eg: user1 : 1.1.1.1/24, user2: 2.2.2.1/24, user3: 3.3.3.1/24 
	}

Continue editing main.tf

	resource "aci_subnet" "bd1_subnet" {
  		bridge_domain_dn = "${aci_bridge_domain.bd1.id}"
  		name             = "Subnet"
  		ip               = "${var.bd_subnet}"
  	}

On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1


	
### Task 6:
#### Create a Filter
A filter classifies a collection of network packet  attributes

Filter is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

Create 2 filters. One related to ICMP and the second related to https

	resource "aci_filter" "allow_https" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "allow_https"
	}
	resource "aci_filter" "allow_icmp" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "allow_icmp"
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	
### Task 7:
#### Create a Filter entry
Filter entry is a network packet  attributes. It selects a packets based on the attributes specified.

Create a filter entry for https and icmp

Filter Entry is a child object of a Filter. You will have to pass the Filter's (parents) DN (Distinguished Name)

	resource "aci_filter_entry" "https" {
  		name        = "https"
  		filter_dn   = "${aci_filter.allow_https.id}"
  		ether_t     = "ip"
  		prot        = "tcp"
  		d_from_port = "https"
  		d_to_port   = "https"
  		stateful    = "yes"
	}

		resource "aci_filter_entry" "icmp" {
  		name        = "icmp"
  		filter_dn   = "${aci_filter.allow_icmp.id}"
  		ether_t     = "ip"
  		prot        = "icmp"
  		stateful    = "yes"
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

### Task 8:
#### Create a Contact
Contract is a set of rules governing communication between EndPoint Groups

Contract is a child object of a tenant. You will have to pass the tenant's (parents) DN (Distinguished Name)

	resource "aci_contract" "contract_epg1_epg2" {
  		tenant_dn = "${aci_tenant.terraform_ten.id}"
  		name      = "Web"
	}
	
On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1
	
### Task 9:
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
	
### Task 10:
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
	
###Task 11:
#### Create 2 End Point Groups(EPGs). 	Relate each EPG to a VRF and define and Endpoint selector.

End Points are devices which attach to the network either virtually or physically, 

e.g:
Ec2 instance
Virtual Machine
Physical Server (running Bare Metal or Hypervisor)
External Layer 2 device
External Layer 3 device
VLAN
Subnet
Firewall
Load balancer

EPG is a logical collection of End Points 

An EPG should be likbed to a VRF.

An EPG must also be linked to a Bridge Domain. End Points of the EPG will be part of this Bridge Domain.

A consumed contract (outbound rule) and a provided contract (inbound rule) must also be added for inter EPG communication 

EPG is a child object of a Cloud Application Profile. You will have to pass the Cloud Application Profiles's (parents) DN (Distinguished Name)


resource "aci_cloud_e_pg" "cloud_apic_epg1" {                                                        
  name                             = "epg1"                                                         
  cloud_applicationcontainer_dn    = "${aci_cloud_applicationcontainer.app1.id}"                    
  relation_fv_rs_prov              = ["${aci_contract.contract_epg1_epg2.name}"]                    
  relation_fv_rs_cons              = ["${aci_contract.contract_epg1_epg2.name}"]                    
  relation_cloud_rs_cloud_e_pg_ctx = "${aci_vrf.vrf1.name}"                                         
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector1" {                                        
  cloud_e_pg_dn    = "${aci_cloud_e_pg.cloud_apic_epg1.id}"                                          
  name             = "devnet-ep1-select={usernumber}" #input your usernumber                                                           
  match_expression = "custom:Name=='devwks-{usernumber}-ep1'" #input your usernumber                                             
}

resource "aci_cloud_e_pg" "cloud_apic_epg2" {                                                        
  name                             = "epg1"                                                         
  cloud_applicationcontainer_dn    = "${aci_cloud_applicationcontainer.app1.id}"                    
  relation_fv_rs_prov              = ["${aci_contract.contract_epg1_epg2.name}"]                    
  relation_fv_rs_cons              = ["${aci_contract.contract_epg1_epg2.name}"]                    
  relation_cloud_rs_cloud_e_pg_ctx = "${aci_vrf.vrf1.name}"                                         
}

resource "aci_cloud_endpoint_selector" "cloud_ep_selector2" {                                        
  cloud_e_pg_dn    = "${aci_cloud_e_pg.cloud_apic_epg1.id}"                                          
  name             = "devnet-ep2-select-{usernumber}" #input your usernumber                                                             
  match_expression = "custom:Name=='devwks-{usernumber}-ep2'" #input your usernumber                                             
}
  	
 On the console
	
	terraform plan -parallelism=1

and then on success

	terraform apply -parallelism=1

### Task 5:
#### Create a Cloud Context Profile

Cloud Context Profile is a new class in ACI which ties the AWS Regions, CIDRs and Subnets to a VRF

Cloud Context Profile is a child of a Tenant

Cloud Context Profile needs to be associated to a VRF


resource "aci_cloud_context_profile" "context_profile" {                                            
  name                     = "devnet-admin-cloud-ctx-profile"                                       
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
  
### Task 4:
#### Create a Cloud CIDR

Create a Cloud CIDR for and attach it to the cloud context profile

data "aci_cloud_cidr_pool" "prim_cidr" {                                                            
  cloud_context_profile_dn = "${aci_cloud_context_profile.context_profile.id}"                      
  addr                     = "10.23{usernumber}.231.1/16" #input usernumber                                                      
  name                     = "10.23{usernumber}.231.1/16" #input usernumber                                                     
}

### Task 4:
#### Create a Cloud Subnet

Create a Cloud Subnet for your ec2 instances. This subnet should be from the CIDR allocated earlier and should be attached to an Availability Zone on AWS

resource "aci_cloud_subnet" "cloud_apic_subnet" {                                                   
  cloud_cidr_pool_dn            = "${data.aci_cloud_cidr_pool.prim_cidr.id}"                        
  name                          = "10.23{usernumber}.231.1/24"  #input usernumber                                               
  ip                            = "10.23{usernumber}.231.1/24"  #input usernumber                                               
  relation_cloud_rs_zone_attach = "uni/clouddomp/provp-aws/region-us-west-1/zone-us-west-1a"        
}

### Task :
#### Create an output

Output information for the ACI created VPC for EC2 instance to consume

output "demo_vpc_name" {                                                                            
  value = "context-[${aci_vrf.vrf1.name}]-addr-[${aci_cloud_context_profile.context_profile.primary_cidr}]"
}


#Output

If all the configuration went through correctly and the varibles in variables.tf are input correctly, you are ready to connect the VMs

- 1. Log into the vcenter client 
- 2. Go to Networking and check if the ACI DVS is created 
- 3. Check if the port group for the EPGs have been created. It should match with your tenant/application_profile/epg. eg lab-user-1 should have a port group <strong>tenant-user-1/ap1/epg1</strong> and <strong>tenant-user-1/ap1/epg2</strong> , lab-user-3 should have a port group <strong>tenant-user-3/ap1/epg1</strong> and <strong>tenant-user-3/ap1/epg2</strong>
- 4. Spin up a VM and attach a VNIC with the EPG port group created
- 5. Once the VM is up assign an IP address to the attached portgroup interface from the configured subnet
- 6. Repeat the same for the other VM and assign it to the other EPG portgroup
- 7. Make sure the VMs are able to ping each other 


##Bonus Exercise:
In the same directory, there is <em>vcenter.tf.bkp</em>

This has the example of spinning up a VM on vcenter and associating the vNIC to the correct EPG portgroup

	mv vcenter.tf.bkp vcenter.tf
	
It makes use of same <em>variable.tf</em>
Modify <em>variable.tf</em> according to your vcenter environment

<strong>Note: The VMs will take about an hour to spin up as we are using a template and the connection to Terraform might be terminated. If so, run terraform plan and apply again</strong>


#Resources:

Terraform ACI provider: Use branch <strong>master</strong>
<https://github.com/ciscoecosystem/terraform-provider-aci>

ACI Go Client: Use branch <strong>master</strong>
<https://github.com/ciscoecosystem/aci-go-client>




