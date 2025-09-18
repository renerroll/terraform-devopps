# Create a route table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id                              # Associate the route table with our VPC

  tags = {
    Name = "${var.vpc_name}-public-rt"                  # Tag for the route table
    Environment = "lesson-5"
  }
}

# Add a route to the Internet via the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id    # ID of the route table
  destination_cidr_block = "0.0.0.0/0"                  # All IP addresses (default route)
  gateway_id             = aws_internet_gateway.igw.id  # Use the Internet Gateway as the target
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id            # ID of the route table
  count          = length(var.public_subnets)           # Associate with each public subnet
  subnet_id      = aws_subnet.public[count.index].id
}
