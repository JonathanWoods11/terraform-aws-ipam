# This configuration is described in README.md

locals {
  top_cidr = "10.0.0.0/8"
}

module "subnets_level_1" {
  source  = "drewmullen/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = local.top_cidr
  networks = [
    {
      name    = "us-east-1"
      netmask = 16
    },
    {
      name    = "us-west-2"
      netmask = 16
    },
  ]
}

module "subnets_level_2_east_1" {
  source  = "drewmullen/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = module.subnets_level_1.network_cidr_blocks["us-east-1"]
  networks = [
    {
      name    = "team_a"
      netmask = 20
    },
    {
      name    = "team_b"
      netmask = 20
    },
  ]
}

module "subnets_level_3_team_b_east_1" {
  source  = "drewmullen/subnets/cidr"
  version = "1.0.0"

  base_cidr_block = module.subnets_level_2_east_1.network_cidr_blocks["team_b"]
  networks = [
    {
      name    = "prod"
      netmask = 28
    },
    {
      name    = "dev"
      netmask = 28
    },
  ]
}


output "base_cidrs" {
  value = {
    top_cidr                      = module.subnets_level_1.base_cidr_block
    subnets_level_2_east_1        = module.subnets_level_1.network_cidr_blocks["us-east-1"]
    subnets_level_3_team_b_east_1 = module.subnets_level_2_east_1.network_cidr_blocks["team_b"]
  }
}

output "l3_cidrs" {
  value = {
    prod = [module.subnets_level_3_team_b_east_1.network_cidr_blocks["prod"]]
    dev  = [module.subnets_level_3_team_b_east_1.network_cidr_blocks["dev"]]
  }
}

module "basic" {
  source   = "../.."
  top_cidr = [local.top_cidr]

  pool_configurations = {
    us-east-1 = {
      cidr   = [module.subnets_level_1.network_cidr_blocks["us-east-1"]]
      locale = "us-east-1"

      sub_pools = {

        team_a = {
          cidr = [module.subnets_level_2_east_1.network_cidr_blocks["team_a"]]
        }

        team_b = {
          cidr = [module.subnets_level_2_east_1.network_cidr_blocks["team_b"]]
          sub_pools = {
            prod = {
              cidr = [module.subnets_level_3_team_b_east_1.network_cidr_blocks["prod"]]
            }
            dev = {
              cidr = [module.subnets_level_3_team_b_east_1.network_cidr_blocks["dev"]]
            }
          }
        }
      }
    }
  }
}
# us-west-2 = {
#   description = "us-west-2 top level pool"
#   cidr        = ["10.0.0.0/16"]
#   locale      = "us-west-2"

#   sub_pools = {

#     sandbox = {
#       cidr                 = ["10.0.48.0/20"]
#       # ram_share_principals = [var.dev_ou_arn]
#     }

#     prod = {
#       cidr = ["10.0.32.0/20"]

#       sub_pools = {
#         team_a = {
#           cidr                 = ["10.0.32.0/28"]
#           # ram_share_principals = [var.prod_account] # prod account
#         }

#         team_b = {
#           cidr                 = ["10.0.32.32/28"]
#           # ram_share_principals = [var.prod_account] # prod account
#         }
#       }
#     }
#   }
# }
