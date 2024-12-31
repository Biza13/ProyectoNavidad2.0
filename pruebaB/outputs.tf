output "security_group_id" {
  value = aws_security_group.lb_security.id
}

output "alb_url" {
  description = "La URL pública para la web"
  value = aws_lb.balanceador.dns_name
}
