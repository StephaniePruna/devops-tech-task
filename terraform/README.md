## Infrastructure
This folder contains Terraform configurations files that will:
1. Create an ECS Cluster, Service ASG and task definition that runs a docker image
2. Create a VPC, subnets, Internet Gateway, NAT gateway and Route Table for the service
3. Create an Autoscaling Group, Load Balancer, security group, target group and listener
4. Create the required IAM roles for the Instance, Service and Task


Please note that you will either need to update the data reference for an existing ECR repository or create a new one and push up the docker image you wish this task to run.