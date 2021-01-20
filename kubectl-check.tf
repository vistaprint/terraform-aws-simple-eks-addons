resource "null_resource" "check_aws_credentials_are_available" {
  triggers = {
    always_run = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      sh -c '
        aws sts get-caller-identity
        if [ $? -ne 0 ]; then
          echo "There was some issue trying to execute the AWS CLI."
          echo "This might mean no valid credentials are configured."
          exit 1
        fi'
      EOT
  }
}
