import tropo_mods.auto_ec2 as auto_ec2
from troposphere import Template, Join

t = Template()
my_instance = auto_ec2.AutoEc2(t, ami_name="ami-083e2c2b01e27ac48", asg=False)

my_instance.add_sg(port="3000", cidrIp="0.0.0.0/0")
my_instance.add_ud(Join("", ["#!/bin/bash -xe\n", "./home/ec2-user/cp-board-linux-amd64-0.0.1 &"]))
my_instance.add_profile(access_to="codepipeline:*")

my_instance.print_to_yaml()
