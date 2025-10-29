########################################################################
############                   zip bundle                   ############
########################################################################

# Archive a single file.

# resource "archive_file" "source" {
#   type        = "zip"
#   source_file = abspath("${path.module}/lambda-function/index.js")
#   output_path = abspath("${path.module}/output/lambda.zip")
# }

output "a" {
    value = abspath("${path.module}/lambda-function/index.js")
}

output "b" {
    value = abspath("./lambda-function/index.js")
}

output "c" {
    value = pathexpand("./lambda-function/index.js")
}

output "d" {
    value = path.module
}

output "e" {
    value = path.root
}

output "f" {
    value = path.cwd
}