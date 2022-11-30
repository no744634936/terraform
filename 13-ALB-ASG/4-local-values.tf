#local values 用来定义一些复杂的表达，例如多个variable组成一个variable
#这样就可以避免重复复杂的表达

locals {
  owners = var.business_divsion
  environment = var.environment
  name = "${var.business_divsion}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment     
  }

}

