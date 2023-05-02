locals {
  binary_name  = "bootstrap"
  binary_path  = "${path.module}/build/bin/${local.binary_name}"
  archive_path = "${path.module}/build/bin/${local.binary_name}.zip"
}

output "binary_path" {
  value = local.binary_path
}
