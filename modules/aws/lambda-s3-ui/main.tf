########################################################################
############                   zip bundle                   ############
########################################################################

# Archive a single file.

resource "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/lambda-function/index.js"
  output_path = "${path.module}/output/lambda.zip"
}

########################################################################
############                  Main lambda                   ############
########################################################################

module "sg" {
  source = "../security-group"
  count = var.sg_config.create ? 1 : 0

  name = "${var.lambda_name}-lambda-access"
  vpc_id = var.sg_config.vpc_id
}

########################################################################
############                  Main lambda                   ############
########################################################################

module "lambda" {
  source = "../lambda"

  function_name = var.lambda_name
  file_path     = archive_file.source.output_path

  vpc_config = {
    subnet_ids                  = var.vpc_config.subnets
    security_group_ids          = concat(var.vpc_config.sg_ids, module.sg[*].id)
  }
}