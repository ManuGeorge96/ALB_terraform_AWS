#SECTION - 1
###################################################################
module "vpc-ALB" {
  source = "./modules"
  cidr_vpc = var.cidr_vpc
  ingress_ports = var.in_ports
  bits = var.no_of_bits
  project = var.project
}
######################################################################
#SECTION - 2
######################################################################
resource "aws_launch_configuration" "Launch-Configuration" {
  name_prefix = "${var.project}-"
  image_id = data.aws_ami.AMI.id
  instance_type = var.type
  key_name = aws_key_pair.ALB-key.key_name
  user_data = file("setup.sh")
  security_groups = [ module.vpc-ALB.security_group_id ]
  lifecycle {
    create_before_destroy = true
  }
} 
#######################################################################
#SECTION - 3
#######################################################################
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
  tag {
    key = "Name"
    value = "${var.project}"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
#############################################################################
#SECTION - 4
#############################################################################
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
  lifecycle {
    create_before_destroy = true
  }
}
################################################################################
#SECTION - 5
################################################################################
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
################################################################################
#SECTION - 6
################################################################################
resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND "
      status_code  = "500"
     }
  }
  depends_on = [ aws_lb.ALB ]
}
################################################################################
#SECTION - 7
################################################################################
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
################################################################################
#SECTION - 8
#################################################################################
resource "aws_key_pair" "ALB-key" {
  key_name = "for_alb"
  public_key = file("alb.pub")
}
