variable "power_tools_version" {
    type = string
    description = "Version of power tools to use"
    default = ""
}

variable "build_runtime" {
    type = string
    description = "Version of Python to build the powertools layer with"
    default = "python3.12"
}

variable "compatible_runtimes" {
    type = list(string)
    description = "Allowed python versions to use"
    default = ["python3.6", "python3.7", "python3.8", "python3.9", "python3.10", "python3.11", "python3.12"]
}

variable "layer_name" {
    type = string
    description = "Name to give the lambda layer"
    default = null
}