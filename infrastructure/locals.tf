locals {
  instances = concat([module.ec2.proxy_data], module.ec2.servers_data, [module.bastion.bastion_data])
  ansible_inventory_groups = {
    for role in distinct([for inst in local.instances : inst.tags.Role]) : role => [for inst in local.instances : inst.ip if inst.tags.Role == role]
  }
}
