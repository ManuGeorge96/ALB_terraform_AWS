# ALB_terraform_AWS

## What is Application Load Balancer?

The Application load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones based on the Header value specified in the Listner Rules. This methode will increase the availability of the application.

## Resource Used

-  Cloud VPC
-  Subnets
-  Security Groups
-  Key Pair
-  Internet Gateway
-  Route Table
-  Auto Scaling Group
-  Launch Configuration
-  Application Load Balancer

## About

This is a project written in Terraform to bild an Infra based on Application Load Balancing, Here we have an Autoscaling Group so that it monitors application servers and automatically adjusts capacity to maintain steady, predictable performance at the lowest possible cost depending on the values set to <b>min</b>, <b>max</b> and <b>desired</b> on the configuration. On top of it we have Application Load balancer which will balance the load accross the target groups specified, based on the Host header mentioned in the Listner rules.
This Project is designed to have, one Target Group with EC2 instances and a listner with a rule.
This terraform code can be used on any AWS regions.

## Outline

[<img align="center" alt="Unix" width="600" src="https://raw.githubusercontent.com/ManuGeorge96/ManuGeorge96/master/Tools/ALB.drawio.png" />][ln]

## Prerequisites

-  Terraform must be installed
-  AWS User with IAM Permissions
-  Idea about IP subneting and AWS regions

## How to Use the Code

-  ```sh
     git clone https://github.com/ManuGeorge96/ALB_terraform_AWS.git
   ```
-  ```sh
     cd ALB_terraform_AWS
   ```
-  Update <b>terraform.tfvars</b>
   -   <b>region</b> : AWS Region for building this Infra
   -   <b>access_key</b> and <b>secret_key</b> 
   -   <b>cidr_vpc</b>  :  CIDR for the new VPC
   -   <b>type</b> : Instance Type
   -   <b>in_ports</b> : ingress ports required for the EC2 instances. Need to specify as a list Eg: [ "21", "80", "443" ]
   -   <b>no_of_bits</b> : number of additional bits with which to extend the prefix. For example, if given a prefix ending in /16 for <b>cidr_vpc</b> and a <b>no_of_bits</b> value of 4, the resulting subnet address will have length /20.
   -   <b>desired</b> : Desired number of EC2 Instances.
   -   <b>max</b> : Maximum number of EC2 Instances that can be launched by Auto Scaling Group.
   -   <b>min</b> : Minimum number of EC2 instances that needs to be under the Auto Scaling Group.
-  You may also edit provision script <b>setup.sh</b>
-  Specify Header value on <b>SECTION - 7</b> inside main.tf
-  ```sh
      terraform init
      terraform apply
   ```   

## Behind The Stage

It has got two main.tf files one in the root folder and other in the ./modules. main.tf in root folder describes about creation of Autoscaling Group, Application Load Balancer with Listner and Listner Rules. ./modules/main.tf describes about the creation of the VPC, subnets, security Groups, Route Table, Internet Gateway, etc.

main.tf

-  SECTION - 1
   -  Section for calling the module, includes the variables required for the module.
-  SECTION - 2
   -  Creation of Launch Configuration.
   -  Specifies how the EC2 instance should look like.
-  SECTION - 3
   -  Creation of Auto-Scaling Group with the above created Launch Configuration.
-  SECTION - 4
   -  Target Group Creation which is required for the Load Balancer for Load Balancing.
   -  Here we specify the Health Check
-  SECTION - 5
   -  Creation of Application Load Balancer.
-  SECTION - 6
   -  Creation of Listner.
   -  Port to which the Load Baancer should Listen.
-  SECTION - 7
   -  Creation of Listner Rules.
   -  Specifies the Host Header here.   



[ln]: https://www.linkedin.com/in/manu-george-03453613a
