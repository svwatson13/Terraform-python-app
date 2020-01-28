# Set a provider
provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "python_app" {
  ami           = var.ami
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = <<EOH
curl -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 0755 jq
# Do some kind of JSON processing with ./jq
EOH
  }
