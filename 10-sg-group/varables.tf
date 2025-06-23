variable "environment" {
    type = string
    default = "dev"
}

variable "project" {
    type = string
    default = "roboshop"
}


variable "frontend_sg_name" {
    default = "fronend"
}

variable "frontend_sg_description" {
  default = "SG_group Created for Instace Creation "
}

