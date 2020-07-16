# co-int-test-gcarroll

#Instructions for setting up Application

Within the repo is everything needed to setup the application and have it running - there are some prerequisite steps that need to be carried out:

1. Create an S3 bucket and insert the webpage configuration. Upon launch of the ASG, the EC2s will copy the files from here to local.
2. Make sure you have the below details at hand:

A tfvars will need creating in your directory:
- access_key (AWS access key)
- secret_key (AWS secret key)
- region (AWS region)
- key_name (AWS SSH key)
- iam_instance_profile (AWS IAM profile for access to S3)*

4. Output of terraform script is the address you use on browser e.g. co-elb-2071334799.eu-west-2.elb.amazonaws.com

5. Edit Variables file to include your IP - to access EC2s via SSH if required


Steps to Run:

1. Terraform Init
2. Terraform Plan
3. Terraform Apply

Voila! 2 web servers in separate AZs behind a load balancer! 



*Below is the Config for the Instance Profile - alter to match your resources

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<<bucket-name>>"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::<<bucket-name>>/*"
            ]
        }
    ]
}

Website template sourced from https://github.com/mdn/beginner-html-site-scripted

 
