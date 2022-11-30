#! /bin/bash
# Instance Identity Metadata Reference - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html
sudo yum update -y
sudo amazon-linux-extras install nginx1
sudo echo '<h1>Welcome to StackSimplify - APP-1</h1>' | sudo tee /usr/share/nginx/html/index.html
sudo mkdir /usr/share/nginx/html/app1
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - APP-1</h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /usr/share/nginx/html/app1/index.html
sudo curl http://169.254.169.254/latest/dynamic/instance-identity/document -o /usr/share/nginx/html/app1/metadata.html
sudo systemctl enable nginx
sudo systemctl start  nginx