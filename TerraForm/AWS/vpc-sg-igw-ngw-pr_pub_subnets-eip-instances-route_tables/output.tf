output "dc_out" {
  value = aws_vpc.dc1
}

output "azs_out" {
  value = data.aws_availability_zones.azs
}