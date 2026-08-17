output "ip_master" {
  value = aws_instance.master.public_ip
}

output "ip_node_1" {
  value = aws_instance.node_1.public_ip
}

output "ip_node_2" {
  value = aws_instance.node_2.public_ip
}
