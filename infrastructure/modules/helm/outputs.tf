output "lb_arn" {
  description = "dns url of ingress lb"
  value = data.aws_lb.aws_lb.arn
}