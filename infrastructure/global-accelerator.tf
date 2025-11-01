resource "aws_globalaccelerator_accelerator" "accelerator" {
  name = "${var.project_name}-global-accelerator"
  ip_address_type = "IPV4"
  enabled = true
}

resource "aws_globalaccelerator_listener" "listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.accelerator.arn
  protocol = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "endpoint_group_primary_region" {
  listener_arn = aws_globalaccelerator_listener.listener.arn
  endpoint_group_region = var.region.primary_region
  endpoint_configuration {
    endpoint_id = module.helm_primary_region.lb_arn
    weight = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "endpoint_group_secondary_region" {
  listener_arn = aws_globalaccelerator_listener.listener.arn
  endpoint_group_region = var.region.secondary_region
  endpoint_configuration {
    endpoint_id = module.helm_secondary_region.lb_arn
    weight = 100
  }
}

output "ga_dns" {
  description = "global accelerator dns"
  value = aws_globalaccelerator_accelerator.accelerator.dns_name
}