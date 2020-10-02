module "open_vpn_instance" {
  count = var.enable_separate_openvpn_instance ? 1 : 0

  source                    = "./instance_deployment"
  aws_credentials_profile   = var.aws_credentials_profile
  aws_region                = var.aws_region
  ingress_access_ip_address = var.ingress_access_ip_address
  key_pair_name             = var.key_pair_name
  additional_tags           = merge({ Name = "Open Vpn Server" }, var.additional_tags)
  user_data_template        = file("${path.module}/templates/open-vpn-init.tpl")
  prefix_identifier         = "open-vpn-"
}

module "pi_hole_instance" {
  count = var.enable_separate_pihole_instance ? 1 : 0

  source                     = "./instance_deployment"
  aws_credentials_profile    = var.aws_credentials_profile
  aws_region                 = var.aws_region
  ingress_access_ip_address  = var.ingress_access_ip_address
  pi_hole_web_admin_password = var.pi_hole_web_admin_password
  key_pair_name              = var.key_pair_name
  additional_tags            = merge({ Name = "Pi Hole Server" }, var.additional_tags)
  user_data_template         = file("${path.module}/templates/pi-hole-init.tpl")
  prefix_identifier          = "pi-hole-"
}

module "additional_pihole_instance_sg_rules" {
  count      = var.enable_separate_openvpn_instance ? 1 : 0
  depends_on = [module.pi_hole_instance, module.open_vpn_instance]

  source                     = "./sg_rules"
  instance_access_ip_address = module.open_vpn_instance.public_ip
  pi_hole_instance_sg_id     = module.pi_hole_instance.security_group_id

}

module "shared_instance" {
  count = var.split_instances ? 0 : 1

  source                     = "./instance_deployment"
  aws_credentials_profile    = var.aws_credentials_profile
  aws_region                 = var.aws_region
  ingress_access_ip_address  = var.ingress_access_ip_address
  pi_hole_web_admin_password = var.pi_hole_web_admin_password
  key_pair_name              = var.key_pair_name
  additional_tags            = merge({ Name = "Pi Hole / Open Vpn Server" }, var.additional_tags)
  user_data_template         = file("${path.module}/templates/open-vpn-pi-hole-joint-init.tpl")
  prefix_identifier          = "pi-hole-open-vpn-shared-"
}
