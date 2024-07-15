resource "aws_vpc" "hello_world" {
    cidr_block = var.vpc_cidr_block
    tags = {
      "Name" = "${var.name}-Ecs-Vpc"
    }
}

resource "aws_subnet" "private" {
    count             = length(var.availability_zones)
    availability_zone = element(var.availability_zones,count.index)
    vpc_id            = aws_vpc.hello_world.id
    cidr_block        = element(var.private_subnet_cidr_blocks,count.index)
    tags = {
        "Name" = "private-${count.index+1}"
    }
}

resource "aws_subnet" "public" {
    count                   = length(var.availability_zones)
    availability_zone       = element(var.availability_zones,count.index)
    vpc_id                  = aws_vpc.hello_world.id
    cidr_block              = element(var.public_subnet_cidr_blocks,count.index)
    map_public_ip_on_launch = true
    tags = {
       "Name" = "public-${count.index+1}"
    }
}


resource "aws_internet_gateway" "hello_world_gw" {
    depends_on = [                                            
      aws_vpc.hello_world
    ]
    vpc_id = aws_vpc.hello_world.id
    tags = {
        "Name" = "${var.name}-Ecs-gw"
    }
}

resource "aws_route_table" "public" {
    depends_on = [
      aws_internet_gateway.hello_world_gw
    ]
    vpc_id = aws_vpc.hello_world.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.hello_world_gw.id
    }
    
    tags = {
      "Name" = "pub-routes"
    }   
}


resource "aws_route_table" "private" {
    vpc_id = aws_vpc.hello_world.id
    tags = {
      "Name" = "private"
    }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
  
}

resource "aws_eip" "ecs_eip" {
  vpc = true
}
resource "aws_nat_gateway" "ecs_nat" {
    depends_on = [
      aws_subnet.private
    ]
    allocation_id = aws_eip.ecs_eip.id
    subnet_id     = aws_subnet.public.0.id

}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.ecs_nat.id
  destination_cidr_block = "0.0.0.0/0"
}