variable "cidr_vpc" {
  default = "172.69.0.0/16"
}
variable "ingress_ports" {
  type = list
  default = [ "21", "22" ]
}
variable "project" {
  default = "ALB"
}
variable "bits" {
  default = "3"
}
variable "desired" {
  default = "2"
}
