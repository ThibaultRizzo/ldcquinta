# 🚀 LDC Quinta Deployment Guide

## Overview

This guide will help you deploy your website to **https://student.luzqr.com** with:
- ✅ **HTTPS/SSL** (secure connection)
- ✅ **CloudFront CDN** (fast global delivery)
- ✅ **Automatic HTTP → HTTPS redirect**
- ✅ **Custom domain** (student.luzqr.com)
- ✅ **Automatic deployments** via GitHub Actions

## 🎯 Quick Start (Recommended)

### Step 1: Run the Setup Script

```bash
# Make the script executable
chmod +x infrastructure/simple-setup.sh

# Run the setup
./infrastructure/simple-setup.sh
```

This creates:
- S3 bucket for hosting
- Bucket policy for public access
- Initial file upload

### Step 2: Request SSL Certificate (IMPORTANT: Must be in us-east-1)

```bash
# Request the certificate
aws acm request-certificate \
  --domain-name student.luzqr.com \
  --validation-method DNS \
  --region us-east-1
```

**Save the CertificateArn** from the output!

### Step 3: Validate the Certificate

```bash
# Get validation details (replace with your certificate ARN)
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:567440051792:certificate/b4798c95-6a2c-4b6c-a2c6-a0364f6128af \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[0].ResourceRecord'
```
{
    "Name": "_b9729da1f494072d06c266acb38dcf1f.student.luzqr.com.",
    "Type": "CNAME",
    "Value": "_b4ffad05d78298c938359567586f6707.xlfgrmvvlj.acm-validations.aws."
}
**Option A: Automatic (Recommended)**
- Go to AWS Certificate Manager Console
- Click your certificate
- Click "Create records in Route 53" button

**Option B: Manual**
- Copy the CNAME record name and value from the output
- Add it to Route53 hosted zone for luzqr.com

Wait for validation (usually 5-10 minutes):
```bash
# Check status (should show "ISSUED")
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query 'Certificate.Status' \
  --output text
```

### Step 4: Create CloudFront Distribution

Create a file `infrastructure/cloudfront-config.json`:

```json
{
  "CallerReference": "ldcquinta-2025",
  "Comment": "LDC Quinta Website with HTTPS",
  "Enabled": true,
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-student.luzqr.com",
        "DomainName": "student.luzqr.com.s3-website-us-east-1.amazonaws.com",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only"
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-student.luzqr.com",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 3,
      "Items": ["GET", "HEAD", "OPTIONS"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true,
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    }
  },
  "CustomErrorResponses": {
    "Quantity": 2,
    "Items": [
      {
        "ErrorCode": 404,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      },
      {
        "ErrorCode": 403,
        "ResponsePagePath": "/index.html",
        "ResponseCode": "200",
        "ErrorCachingMinTTL": 300
      }
    ]
  },
  "Aliases": {
    "Quantity": 1,
    "Items": ["student.luzqr.com"]
  },
  "ViewerCertificate": {
    "ACMCertificateArn": "YOUR_CERTIFICATE_ARN",
    "SSLSupportMethod": "sni-only",
    "MinimumProtocolVersion": "TLSv1.2_2021"
  },
  "PriceClass": "PriceClass_100",
  "HttpVersion": "http2"
}
```

**Replace `YOUR_CERTIFICATE_ARN`** with your actual certificate ARN, then:

```bash
# Create the distribution
aws cloudfront create-distribution \
  --distribution-config file://infrastructure/cloudfront-config.json \
  --region us-east-1
```
E28QBBU83SB043
d1ksry4j843x26.cloudfront.net
student.luzqr.com.s3-website-us-east-1.amazonaws.com
**Save the Distribution ID and Domain Name** from the output!

### Step 5: Update Route53 DNS

```bash
# Get your hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
  --dns-name luzqr.com \
  --query 'HostedZones[0].Id' \
  --output text | cut -d'/' -f3)

# Create the A record (replace CLOUDFRONT_DOMAIN)
cat > /tmp/route53-record.json << 'EOF'
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "student.luzqr.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "d1ksry4j843x26.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF

# Replace YOUR_CLOUDFRONT_DOMAIN with actual CloudFront domain (e.g., d1234567890.cloudfront.net)
# Then run:
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file:///tmp/route53-record.json
```

### Step 6: Configure GitHub Secrets

**Option A: Automated (Recommended)**

Run the IAM setup script:
```bash
chmod +x infrastructure/setup-iam-user.sh
./infrastructure/setup-iam-user.sh
```

This will:
- Create an IAM user with minimal required permissions
- Generate access keys
- Display credentials to add to GitHub

**Option B: Manual Setup**

See detailed guide: [infrastructure/IAM-SETUP.md](IAM-SETUP.md)

Then add these secrets to GitHub (Settings → Secrets and variables → Actions):

1. **AWS_ACCESS_KEY_ID** - From IAM user creation
2. **AWS_SECRET_ACCESS_KEY** - From IAM user creation  
3. **AWS_S3_BUCKET** - `student.luzqr.com`
4. **AWS_CLOUDFRONT_DISTRIBUTION_ID** - `E28QBBU83SB043` (from Step 4)

### Step 7: Push to GitHub

```bash
# Add all new files
git add .

# Commit
git commit -m "Add AWS infrastructure and deployment pipeline"

# Push (will trigger automatic deployment)
git push origin main
```

## 🔒 HTTPS Security Features

Your site will have:
- ✅ **TLS 1.2+** encryption (minimum)
- ✅ **SNI-based SSL** (modern, efficient)
- ✅ **Automatic HTTP → HTTPS redirect**
- ✅ **Free AWS Certificate** (auto-renewal)
- ✅ **A+ SSL Labs rating** potential

## 🧪 Testing

After deployment (allow 15-30 minutes for DNS propagation):

```bash
# Test HTTP redirect
curl -I http://student.luzqr.com

# Should return 301/302 redirect to HTTPS

# Test HTTPS
curl -I https://student.luzqr.com

# Should return 200 OK

# Test SSL certificate
openssl s_client -connect student.luzqr.com:443 -servername student.luzqr.com < /dev/null
```

## 🔄 Manual Deployment

If you need to deploy manually without GitHub Actions:

```bash
# Set CloudFront distribution ID
export CLOUDFRONT_DISTRIBUTION_ID="E1ABCDEFGHIJK"

# Run deployment script
chmod +x infrastructure/deploy.sh
./infrastructure/deploy.sh
```

## 📊 Monitoring

### Check deployment status:
```bash
# Check CloudFront distribution status
aws cloudfront get-distribution \
  --id YOUR_DISTRIBUTION_ID \
  --query 'Distribution.Status' \
  --output text

# Should show "Deployed"
```

### View CloudFront access logs:
```bash
# List recent objects in bucket
aws s3 ls s3://student.luzqr.com/ --recursive --human-readable
```

## 🐛 Troubleshooting

### Certificate not validating
- Check DNS records in Route53
- Wait up to 30 minutes for DNS propagation
- Verify CNAME record matches certificate validation requirements

### CloudFront shows error
- Check S3 bucket policy allows public read
- Verify origin domain name is correct
- Check custom error pages configuration

### DNS not resolving
- Wait 15-30 minutes for DNS propagation
- Check Route53 record points to correct CloudFront domain
- Verify hosted zone ID is correct

### GitHub Actions failing
- Check all secrets are set correctly
- Verify IAM user has required permissions
- Check CloudFront distribution ID is correct

## 📝 Important Notes

1. **Certificate Region**: ACM certificate MUST be in `us-east-1` for CloudFront
2. **DNS Propagation**: Allow 15-30 minutes after DNS changes
3. **CloudFront Deployment**: Takes 15-20 minutes to deploy changes
4. **Cache Invalidation**: Costs $0 for first 1,000 paths/month, then $0.005 per path
5. **S3 Website Endpoint**: Use website endpoint, not REST endpoint, for CloudFront origin

## 🔗 Useful AWS Console Links

- [S3 Buckets](https://s3.console.aws.amazon.com/s3/buckets)
- [CloudFront Distributions](https://console.aws.amazon.com/cloudfront/v3/home#/distributions)
- [Certificate Manager](https://console.aws.amazon.com/acm/home?region=us-east-1)
- [Route53 Hosted Zones](https://console.aws.amazon.com/route53/v2/hostedzones)
- [IAM Users](https://console.aws.amazon.com/iam/home#/users)

## 💰 Cost Estimate

Monthly costs (for low-traffic site):
- S3 Storage: ~$0.10 (1GB)
- S3 Requests: ~$0.05 (10K requests)
- CloudFront: ~$0.85 (10GB transfer)
- Route53: $0.50 (hosted zone)
- **Total: ~$1.50/month**

SSL Certificate is FREE with AWS Certificate Manager!

## 🎉 Success!

Once everything is set up, your website will be live at:
**https://student.luzqr.com** 🎊

Any push to the `main` branch will automatically deploy!

