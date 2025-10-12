# AWS Infrastructure Setup Instructions

## Prerequisites

1. AWS CLI installed and configured
2. AWS account with appropriate permissions
3. Domain `luzqr.com` already in Route53

## Manual Setup Steps (Simpler Approach)

### Step 1: Create S3 Bucket for Website Hosting

```bash
# Set your variables
BUCKET_NAME="student.luzqr.com"
REGION="us-east-1"

# Create bucket
aws s3 mb s3://${BUCKET_NAME} --region ${REGION}

# Enable static website hosting
aws s3 website s3://${BUCKET_NAME} --index-document index.html --error-document index.html

# Set bucket policy for public read
cat > /tmp/bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket ${BUCKET_NAME} --policy file:///tmp/bucket-policy.json

# Disable block public access
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration \
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

### Step 2: Request ACM Certificate (MUST be in us-east-1 for CloudFront)

```bash
# Request certificate (this will return a CertificateArn)
aws acm request-certificate \
  --domain-name student.luzqr.com \
  --validation-method DNS \
  --region us-east-1

# Get the validation record (replace CERTIFICATE_ARN with the one from above)
aws acm describe-certificate \
  --certificate-arn CERTIFICATE_ARN \
  --region us-east-1

# Add the DNS validation record to Route53 (will be shown in the output)
# Or use the AWS Console to validate automatically
```

### Step 3: Create CloudFront Distribution

```bash
# Get your hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
  --dns-name luzqr.com \
  --query 'HostedZones[0].Id' \
  --output text | cut -d'/' -f3)

# Create CloudFront distribution (after certificate is validated)
# This is easier to do via AWS Console due to complexity
# Go to CloudFront > Create Distribution
# - Origin Domain: student.luzqr.com.s3.us-east-1.amazonaws.com
# - Viewer protocol policy: Redirect HTTP to HTTPS
# - Alternate domain name (CNAME): student.luzqr.com
# - Custom SSL certificate: Select your validated certificate
# - Default root object: index.html
```

### Step 4: Create Route53 Record

```bash
# Get CloudFront distribution domain name (from console or CLI)
CLOUDFRONT_DOMAIN="xxxxxxxxxxxxxx.cloudfront.net"

# Create Route53 alias record
cat > /tmp/route53-change.json << EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "student.luzqr.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "${CLOUDFRONT_DOMAIN}",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id ${HOSTED_ZONE_ID} \
  --change-batch file:///tmp/route53-change.json
```

## CloudFormation Setup (Automated - Recommended)

```bash
# Deploy the stack
aws cloudformation create-stack \
  --stack-name ldcquinta-website \
  --template-body file://infrastructure/cloudformation-template.yaml \
  --parameters \
    ParameterKey=DomainName,ParameterValue=student.luzqr.com \
    ParameterKey=RootDomainName,ParameterValue=luzqr.com \
  --region us-east-1

# Wait for stack creation
aws cloudformation wait stack-create-complete \
  --stack-name ldcquinta-website \
  --region us-east-1

# Get outputs
aws cloudformation describe-stacks \
  --stack-name ldcquinta-website \
  --region us-east-1 \
  --query 'Stacks[0].Outputs'
```

## Get Stack Outputs

After deployment, retrieve these values for GitHub Actions:

```bash
# Get bucket name
aws cloudformation describe-stacks \
  --stack-name ldcquinta-website \
  --region us-east-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`WebsiteBucketName`].OutputValue' \
  --output text

# Get CloudFront Distribution ID
aws cloudformation describe-stacks \
  --stack-name ldcquinta-website \
  --region us-east-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionID`].OutputValue' \
  --output text
```

## Configure GitHub Secrets

Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_S3_BUCKET`: student.luzqr.com (or from stack output)
- `AWS_CLOUDFRONT_DISTRIBUTION_ID`: From stack output

## Verify Certificate Validation

```bash
# Check certificate status
aws acm describe-certificate \
  --certificate-arn YOUR_CERTIFICATE_ARN \
  --region us-east-1 \
  --query 'Certificate.Status' \
  --output text
```

Should return `ISSUED` when ready.

