module "component" {

    for_each = var.components
    source = "../../terraform-aws-roboshop-components"
    component = each.key
    rule_priority = each.value.rule_priority
  
}