variable "environment" {
    type = string
    default = "dev"
}

variable "project" {
    type = string
    default = "roboshop"
}


variable "frontend_sg_name" {
    default = "frontend"
}

variable "frontend_sg_description" {
  default = "SG_group Created for Instace Creation "
}


variable "bastion_sg_name" {
    default = "bastion"
}

variable "bastion_sg_description" {
  default = "SG_group Created for Instace Creation "
}

variable "vpn_ports" {
  
  default = [22,443,1194,943]
}

variable "mongodb_ports" {
  
  default = [22,27017]
}

variable "zone_id" {
    default = "Z0388521KFVW7JPV7X7D"
  
}

variable "zone_name" {
    default = "narendaws-84s.site"
}
