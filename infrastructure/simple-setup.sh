#!/bin/bash

# Simple AWS Setup Script for LDC Quinta
# This script creates the basic infrastructure for hosting the website

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="student.luzqr.com"
REGION="us-east-1"
DOMAIN="student.luzqr.com"
ROOT_DOMAIN="luzqr.com"

echo -e "${GREEN}🚀 LDC Quinta AWS Infrastructure Setup${NC}"
echo "========================================"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials are not configured.${NC}"
    echo "Run: aws configure"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI configured${NC}"
echo ""

# Step 1: Create S3 Bucket
echo -e "${YELLOW}📦 Step 1: Creating S3 bucket...${NC}"
if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${BUCKET_NAME}" --region ${REGION}
    echo -e "${GREEN}✅ Bucket created: ${BUCKET_NAME}${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket already exists: ${BUCKET_NAME}${NC}"
fi

# Step 2: Enable static website hosting
echo -e "${YELLOW}🌐 Step 2: Enabling static website hosting...${NC}"
aws s3 website "s3://${BUCKET_NAME}" \
    --index-document index.html \
    --error-document index.html
echo -e "${GREEN}✅ Static website hosting enabled${NC}"

# Step 3: Disable block public access
echo -e "${YELLOW}🔓 Step 3: Configuring public access...${NC}"
aws s3api put-public-access-block \
    --bucket ${BUCKET_NAME} \
    --public-access-block-configuration \
    "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
echo -e "${GREEN}✅ Public access configured${NC}"

# Step 4: Set bucket policy
echo -e "${YELLOW}📋 Step 4: Setting bucket policy...${NC}"
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
rm /tmp/bucket-policy.json
echo -e "${GREEN}✅ Bucket policy set${NC}"

# Step 5: Upload initial files
echo -e "${YELLOW}📤 Step 5: Uploading website files...${NC}"
cd "$(dirname "$0")/.."
aws s3 sync . "s3://${BUCKET_NAME}" \
    --exclude ".git/*" \
    --exclude ".github/*" \
    --exclude "infrastructure/*" \
    --exclude "README.md" \
    --exclude "Makefile" \
    --exclude ".gitignore" \
    --exclude "*.sh" \
    --cache-control "public, max-age=86400"
echo -e "${GREEN}✅ Files uploaded${NC}"

# Step 6: Get hosted zone ID
echo -e "${YELLOW}🔍 Step 6: Finding Route53 hosted zone...${NC}"
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name ${ROOT_DOMAIN} \
    --query 'HostedZones[0].Id' \
    --output text 2>/dev/null | cut -d'/' -f3 || echo "")

if [ -z "$HOSTED_ZONE_ID" ]; then
    echo -e "${RED}❌ Hosted zone for ${ROOT_DOMAIN} not found${NC}"
    echo "Please create it in Route53 first."
else
    echo -e "${GREEN}✅ Found hosted zone: ${HOSTED_ZONE_ID}${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}🎉 Basic setup completed!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Request ACM Certificate (MUST be in us-east-1):"
echo "   aws acm request-certificate \\"
echo "     --domain-name ${DOMAIN} \\"
echo "     --validation-method DNS \\"
echo "     --region us-east-1"
echo ""
echo "2. Validate the certificate via DNS (check AWS Console)"
echo ""
echo "3. Create CloudFront distribution:"
echo "   - Go to AWS Console > CloudFront > Create Distribution"
echo "   - Origin Domain: ${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
echo "   - Alternate domain: ${DOMAIN}"
echo "   - Use the validated certificate"
echo ""
echo "4. Add Route53 A record pointing to CloudFront"
echo ""
echo "5. Configure GitHub Secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "   - AWS_S3_BUCKET: ${BUCKET_NAME}"
echo "   - AWS_CLOUDFRONT_DISTRIBUTION_ID: (from CloudFront)"
echo ""
echo -e "${YELLOW}📝 For detailed instructions, see infrastructure/setup-instructions.md${NC}"

