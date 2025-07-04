module "uesr" {
    source = "../../terraform-aws-roboshop-components"
    component = "user"
    rule_priority = 10
  
}