variable "components" {
  default = {

    catalogue ={
        rule_priority = 20
    }
     cart ={
        rule_priority = 30
    }
     frontend ={
        rule_priority = 10
    }

    payment ={
        rule_priority = 40
    }

    user ={
        rule_priority = 10
    }
    
    

  }
}