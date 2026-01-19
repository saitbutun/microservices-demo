resource "aws_ecr_repository" "microservices" {
  for_each             = var.services
  name                 = "${var.app_name}/${each.key}" 
  image_tag_mutability = "MUTABLE"
  force_delete         = true 

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_urls" {
  value = { for k, v in aws_ecr_repository.microservices : k => v.repository_url }
}
