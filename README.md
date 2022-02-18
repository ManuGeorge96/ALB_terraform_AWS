[![Generic badge](https://img.shields.io/badge/BUILD-PASS-BLUE.svg)](https://shields.io/)

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

<b>main.tf</b>

-  SECTION - 1
   -  ```sh
        module "vpc-ALB" {
        source = "./modules"
        cidr_vpc = var.cidr_vpc
        ingress_ports = var.in_ports
        bits = var.no_of_bits
        project = var.project
        }
      ```
   -  Section for calling the module, includes the variables required for the module.
-  SECTION - 2
   -  ```sh
         resource "aws_launch_configuration" "Launch-Configuration" {
         name_prefix = "${var.project}-"
         image_id = data.aws_ami.AMI.id
         instance_type = var.type
         key_name = aws_key_pair.ALB-key.key_name
         user_data = file("setup.sh")
         security_groups = [ module.vpc-ALB.security_group_id ]
       ```  
   -  lifecycle ensure the resource has created before destroying.      
   -  Creation of Launch Configuration.
   -  Specifies how the EC2 instance should look like.
-  SECTION - 3
   -  ```sh
        resource "aws_autoscaling_group" "Scaling-Group" {
        name_prefix = "${var.project}-"
        max_size = var.max
        min_size = var.min
        vpc_zone_identifier = module.vpc-ALB.NEWsubids
         default_cooldown = "5"
        launch_configuration = aws_launch_configuration.Launch-Configuration.name
        health_check_type = "EC2"
        desired_capacity = var.desired
        target_group_arns = [ aws_lb_target_group.ALB-Target.arn ]
      ```  
   -  Creation of Auto-Scaling Group with the above created Launch Configuration.
-  SECTION - 4
   -  ```sh
        resource "aws_lb_target_group" "ALB-Target" {
        name_prefix = "ALB"
        port = "80"
        protocol = "HTTP"
        vpc_id = module.vpc-ALB.vpc_id
        health_check {
           healthy_threshold = 2
           interval = 6
           port = 80
           protocol = "HTTP"
           unhealthy_threshold = 2
         }
         stickiness {
         enabled = false
         type = "lb_cookie"
         cookie_duration = 60
        }
      ```  
   -  Target Group Creation which is required for the Load Balancer for Load Balancing.
   -  Here we specify the Health Check
-  SECTION - 5
   -  ```sh
        resource "aws_lb" "ALB" {
        name_prefix = "ALB"
        internal = false
        load_balancer_type = "application"
        security_groups = [ module.vpc-ALB.security_group_full_id ]
        subnets = module.vpc-ALB.NEWsubids
        enable_deletion_protection = false
        depends_on = [ aws_lb_target_group.ALB-Target ]
        tags = {
          Name = "${var.project}"
         }
        }
      ```  
   -  Creation of Application Load Balancer.
-  SECTION - 6
   -  ```sh
       resource "aws_lb_listener" "listner" {
       load_balancer_arn = aws_lb.ALB.arn
       port              = 80
       protocol          = "HTTP"
       default_action {
         type = "fixed-response"
         fixed_response {
           content_type = "text/plain"
           message_body = "NOT FOUND "
           status_code  = "200"
          }
        }
        depends_on = [ aws_lb.ALB ]
       }
       ```  
   -  Creation of Listner.
   -  Port to which the Load Baancer should Listen.
-  SECTION - 7
   -  ```sh
       resource "aws_lb_listener_rule" "main" {
       listener_arn = aws_lb_listener.listner.arn
       priority     = 1
       action {
         type = "forward"
         target_group_arn = aws_lb_target_group.ALB-Target.arn
       }
       condition {
       host_header {
       values = ["ENTER-HOST-HEADER-HERE"]
       }
        }
        }
      ```
   -  Creation of Listner Rules.
   -  Specify the Host Header here.   



[ln]: https://www.linkedin.com/in/manu-george-03453613a
