Alpha WebApp Staging Environment with AWS ECS and Terraform

This project has the Terraform stuff I used to get our Alpha WebApp staging area up on AWS. It uses ECS with Fargate to run our app
(right now, it's just Nginx as a stand in) and also sets up the network, load balancer, and security bits.
The idea is to have a solid way to get staging ready whenever we need it.
What it Does Sets up a private network for us in AWS, with a couple of subnets so it's pretty reliable.
Starts up an ECS cluster using Fargate, so we don't have to worry about the servers underneath.
Runs a Docker container. For now, that's just a plain Nginx web server (nginx version 1.25 alpine) to show things are working before we put the real Alpha WebApp there.
Puts a load balancer in front so we have one address to hit the app.
Handles some security with security groups to make sure only the right traffic gets through.
Also sends the container logs to CloudWatch so we can see what's happening.

I've split the code into a few files:
project_vars.tf: This is where the main settings are, like the AWS region, project names, and the Docker image we want to run. If you need to change things for a deployment, this is usually the file to look at.
provider_setup.tf: Just tells Terraform we're using AWS.
network_layout.tf: This one builds the VPC, subnets, and other network parts.
firewall_rules.tf: This has our security group rules.
application_service.tf: This is the big one that creates the ECS cluster, the app definition, the actual service, and the load balancer.
storage.tf: If you added the S3 bucket part, that's in here.
deployment_outputs.tf: This tells Terraform what info to show us after it's done, like the website address for the app.
Settings
Most settings are in project_vars.tf. For this Alpha WebApp staging setup, I've put in:
AWS Region: ap-south-1 (that's Mumbai)
Application Name: alpha-webapp
Environment: staging
Container Image: nginx:1.25-alpine (our stand in app)
If you want to use a different region or a different Docker image (like when our actual Alpha WebApp image is ready), you'll just change the values in that file.
How to Get it Running
Once you have the things from the prerequisites list:
Get the code: If you haven't got it already, clone the repository and go into the directory.
Start Terraform:
Open your terminal in the project folder and type:
terraform init
This gets the AWS plugin that Terraform needs.
Check the plan (good idea):
See what Terraform plans to do:
terraform plan
This helps you see what it's going to create or change.
Run it:
To build everything in AWS:
terraform apply
Terraform will show the plan again and ask if you're sure. Type yes and press Enter. This part can take a few minutes.
Checking if it Worked
After terraform apply finishes, it will show some outputs. The main one is AlphaWebApp_Staging_URL.
Get the URL: You'll see something like this in your terminal:
AlphaWebApp_Staging_URL = "http://alpha-webapp-staging-alb-somelettersandnumbers.ap-south-1.elb.amazonaws.com"
Open it in your browser:
Copy that URL and put it in your web browser.
You should see the "Welcome to nginx!" page. This means the AWS stuff is set up, Nginx is running, and the load balancer is sending traffic to it. The Nginx container shows that page because its own startup script ran when ECS started the container.
Look at logs (if you want):
The CloudWatch_Log_Group output tells you where the container logs are in AWS CloudWatch. You can go there in the AWS console if you need to see them.
