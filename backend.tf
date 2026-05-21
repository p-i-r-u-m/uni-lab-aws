terraform {
  backend "s3" {
    bucket         = "968313778744-terraform-tfstate" # Твій ID бакету
    key            = "labs/lab1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
  }
}