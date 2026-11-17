output "aws_region" { value = var.aws_region }
output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnets }
output "database_subnet_ids" { value = module.vpc.database_subnets }
output "node_security_group_id" { value = module.eks.node_security_group_id }
output "vpc_cidr_block" { value = module.vpc.vpc_cidr_block }
output "database_subnet_group_name" { value = module.vpc.database_subnet_group_name }
output "ecr_repository_url" { value = aws_ecr_repository.api.repository_url }
output "configure_kubectl" { value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}" }

