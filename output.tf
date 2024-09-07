output "vpc_handson" {
  value = aws_vpc.vpc_handson.id
}
output "public_1a" {
  value = aws_subnet.public_1a.id
}
output "public_1b" {
  value = aws_subnet.public_1b.id
}
output "private_1a" {
  value = aws_subnet.private_1a.id
}
output "private_1b" {
  value = aws_subnet.public_1b.id
}
output "aws_internet_gateway" {
  value = aws_internet_gateway.handson_gw.id
}
output "aws_nat_gateway" {
  value = aws_nat_gateway.nat_gw.id
}
output "public_route" {
  value = aws_internet_gateway.handson_gw.id

}
output "private_route" {
  value = aws_nat_gateway.nat_gw.id
}