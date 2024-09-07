#!/bin/bash

echo "vpc is: $(terraform output vpc_handson)" >> infrastructure.txt
echo "igw is: $(terraform output aws_internet_gateway)" >> infrastructure.txt
