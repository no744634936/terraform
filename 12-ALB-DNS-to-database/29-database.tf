# Create AWS RDS Database
module "rdsdb" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.1.0"
  
  identifier = var.db_instance_identifier    


  #----------------------------------复制粘贴即可区域开始------------------
  engine               = "mysql"
  engine_version       = "8.0.27"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t4g.large"
#   instance_class       = "db.t3.micro"

  allocated_storage     = 20           # The allocated storage in gigabytes
  max_allocated_storage = 100          #Specifies the value for Storage Autoscaling。自动扩容时用到


  db_name  = var.db_name  # Initial Database Name
  username = var.db_username
  create_random_password = false //这个必须是false否则下面的passwor的设置不成功
  password = var.db_password
  port     = 3306

  multi_az               = true   //多个az zone
  #这个 db_subnet_group_name 很重要  
  #Name of DB subnet group. 
  #DB instance will be created in the VPC associated with the DB subnet group. 
  #If unspecified, will be created in the default VPC
  db_subnet_group_name   = module.vpc.database_subnet_group_name //数据库与vpc建立联系
  subnet_ids             = module.vpc.database_subnets   //数据库与subnet 建立联系，两个子网共用一个数据库
  vpc_security_group_ids = [module.rdsdb_sg.security_group_id] //数据库与security group 建立联系


  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  
  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
  #----------------------------------复制粘贴即可区域结束------------------
  tags = local.common_tags
}