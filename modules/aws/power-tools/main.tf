resource "null_resource" "python_lambda_layer_dependencies" {
  triggers = {
    requirements = var.power_tools_version
  }

  provisioner "local-exec" {
    command = "./get_dependencies.sh"
  }
}

resource "aws_lambda_layer_version" "layer" {
  filename   = "layer_code.zip"
  layer_name = var.layer_name == null ? "PowerTool${var.power_tools_version}" : var.layer_name

  compatible_runtimes = var.compatible_runtimes
}