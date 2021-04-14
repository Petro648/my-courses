#!/bin/bash

# create security group
aws ec2 create-security-group --group-name My-SG --description "My security group" --vpc-id vpc-d86ee3b2 | grep GroupId | cut -d'"' -f4 |read GROUPID

aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port 22 --cidr 185.112.172.80/32

# run instance
aws ec2 run-instances --image-id ami-0767046d1677be5a0 --count 1 --instance-type t2.micro --key-name aws-test --security-group-ids $GROUPID --subnet-id subnet-3010645a

# waiting
aws ec2 wait instance-status-ok

#Run a Bash script using Run Command 

aws ssm send-command \
	--document-name "AWS-RunShellScript" \
	--targets '[{"Key":"InstanceIds","Values":["i-0ac23849ef9adaed7"]}]' \
	--parameters '{"commands":[#!/bin/bash,apt update -y, apt upgrade -y, apt install nginx -y, echo "<html>
<head>
<title>All Work</title>
</head>
<body>
<H1>Hello</H1>
<P> if you look this text then your web-server is working </P>
</body>
</html>" > /var/www/html/index.html,
"systemctl restart nginx" ]}'
