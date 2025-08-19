locals {
  ansible_inventory_groups = {
    for role in distinct([for inst in module.ec2.instances : inst.tags.Role]) : role => [for inst in module.ec2.instances : inst.public_ip if inst.tags.Role == role]
  }
}
