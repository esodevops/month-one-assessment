#!/bin/bash

# 1. IMMEDIATE ACCESS SETUP
# Set administrative password for ec2-user
echo "ec2-user:${admin_password}" | chpasswd

# Enable SSH Password Authentication immediately
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# 2. NETWORK WARM-UP
# Wait for NAT Gateway and Route Tables to stabilize across the VPC fabric
sleep 60

# 3. SOFTWARE INSTALLATION
# Install and configure Apache
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# 4. METADATA & CONTENT SETUP (IMDSv2)
# Get the IMDSv2 Token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch the Instance ID using the token
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

# Create the styled HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>TechCorp Web Server</title>
    <style>
    body { 
        font-family: sans-serif; 
        text-align: center; 
        padding-top: 150px; 
        background-color: #f4f4f4; 
    }

    .container { 
        background: white; 
        padding: 40px; 
        border-radius: 10px; 
        display: inline-block; 
        box-shadow: 0 4px 6px rgba(0,0,0,0.1); 
    }

    /* Gradient animation */
    @keyframes gradientMove {
        0% { background-position: 0% 50%; }
        100% { background-position: 100% 50%; }
    }

    h1,
    .container p:first-of-type {
        background: linear-gradient(90deg, #059669, #7c3aed);
        background-size: 200% auto;
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        -webkit-text-fill-color: transparent;
        animation: gradientMove 3s linear infinite;
    }

    .instance-id { 
        font-weight: bold; 
        font-size: 20px; 
        color: #7c3aed;
    }
</style>
</head>
<body>
    <div class="container">
        <h1>Welcome to TechCorp Web Server</h1>
        <p>Infrastructure Managed by TechCorp</p>
        <p>Instance ID: <span class="instance-id">$INSTANCE_ID</span></p>
    </div>
</body>
</html>
EOF