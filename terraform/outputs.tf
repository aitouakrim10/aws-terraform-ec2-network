output "ip_vm_1" {
  value = aws_instance.zenon_vm_1.public_ip
}

output "ip_vm_2" {
  value = aws_instance.zenon_vm_2.public_ip
}
