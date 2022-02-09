output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "security_group_id" {
  value = aws_security_group.Inst-SG.id
}
output "AZs" {
  value = data.aws_availability_zones.AZs.id
}
output "security_group_full_id" {
  value = aws_security_group.allow.id 
}
output "NEWsubids" {
  value = aws_subnet.public-subnets.*.id
}
