#############################################################################
###########                          Notes                        ###########
###########                                                       ###########
########### I am insane                                           ###########
###########                                                       ###########
#############################################################################

module "test" {
  source = "github.com/myoolala/terraform-aws/modules//test-archive-module?ref=next-work"
}

output "a" {
  value = module.test.a
}

output "b" {
  value = module.test.b
}

output "c" {
  value = module.test.c
}

output "d" {
  value = module.test.d
}

output "e" {
  value = module.test.e
}

output "f" {
  value = module.test.f
}