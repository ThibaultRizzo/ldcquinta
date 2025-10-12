#!/bin/bash

# Setup IAM User for GitHub Actions Deployment
# This script creates an IAM user with the necessary permissions

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔐 Setting up IAM User for GitHub Actions${NC}"
echo "=============================================="
echo ""

# Configuration
IAM_USER_NAME="ldcquinta-github-actions"
POLICY_NAME="LDCQuintaDeploymentPolicy"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials are not configured.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI configured${NC}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "Account ID: ${ACCOUNT_ID}"
echo ""

# Step 1: Create IAM User
echo -e "${YELLOW}👤 Step 1: Creating IAM user...${NC}"
if aws iam get-user --user-name ${IAM_USER_NAME} &> /dev/null; then
    echo -e "${YELLOW}⚠️  User ${IAM_USER_NAME} already exists${NC}"
else
    aws iam create-user --user-name ${IAM_USER_NAME}
    echo -e "${GREEN}✅ User created: ${IAM_USER_NAME}${NC}"
fi

# Step 2: Create custom policy with minimal required permissions
echo -e "${YELLOW}📋 Step 2: Creating deployment policy...${NC}"

cat > /tmp/deployment-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketWebsite"
      ],
      "Resource": "arn:aws:s3:::student.luzqr.com"
    },
    {
      "Sid": "S3ObjectAccess",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::student.luzqr.com/*"
    },
    {
      "Sid": "CloudFrontInvalidation",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudFrontDistributionRead",
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListDistributions"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create or update the policy
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

if aws iam get-policy --policy-arn ${POLICY_ARN} &> /dev/null; then
    echo -e "${YELLOW}⚠️  Policy already exists, creating new version...${NC}"
    
    # Delete old versions if at limit (max 5 versions)
    OLD_VERSIONS=$(aws iam list-policy-versions --policy-arn ${POLICY_ARN} --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text)
    for version in $OLD_VERSIONS; do
        aws iam delete-policy-version --policy-arn ${POLICY_ARN} --version-id $version 2>/dev/null || true
    done
    
    aws iam create-policy-version \
        --policy-arn ${POLICY_ARN} \
        --policy-document file:///tmp/deployment-policy.json \
        --set-as-default
else
    aws iam create-policy \
        --policy-name ${POLICY_NAME} \
        --policy-document file:///tmp/deployment-policy.json \
        --description "Permissions for LDC Quinta GitHub Actions deployment"
    echo -e "${GREEN}✅ Policy created: ${POLICY_NAME}${NC}"
fi

rm /tmp/deployment-policy.json

# Step 3: Attach policy to user
echo -e "${YELLOW}🔗 Step 3: Attaching policy to user...${NC}"
aws iam attach-user-policy \
    --user-name ${IAM_USER_NAME} \
    --policy-arn ${POLICY_ARN}
echo -e "${GREEN}✅ Policy attached${NC}"

# Step 4: Create access key
echo -e "${YELLOW}🔑 Step 4: Creating access keys...${NC}"

# Check if user already has access keys
EXISTING_KEYS=$(aws iam list-access-keys --user-name ${IAM_USER_NAME} --query 'AccessKeyMetadata[].AccessKeyId' --output text)

if [ ! -z "$EXISTING_KEYS" ]; then
    echo -e "${YELLOW}⚠️  User already has access keys:${NC}"
    echo "$EXISTING_KEYS"
    echo ""
    read -p "Do you want to create a new access key? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Skipping access key creation${NC}"
        echo ""
        echo -e "${GREEN}✅ IAM user setup complete!${NC}"
        exit 0
    fi
fi

# Create new access key
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name ${IAM_USER_NAME})
ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

echo -e "${GREEN}✅ Access key created${NC}"
echo ""

# Display credentials
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}🎉 IAM User Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  SAVE THESE CREDENTIALS NOW - They won't be shown again!${NC}"
echo ""
echo -e "${GREEN}IAM User:${NC} ${IAM_USER_NAME}"
echo -e "${GREEN}AWS Access Key ID:${NC}"
echo "${ACCESS_KEY_ID}"
echo ""
echo -e "${GREEN}AWS Secret Access Key:${NC}"
echo "${SECRET_ACCESS_KEY}"
echo ""
echo -e "${GREEN}================================================${NC}"
echo ""

# Save to file (will be gitignored)
cat > /tmp/github-secrets.txt << EOF
Add these to your GitHub repository secrets:
(Settings > Secrets and variables > Actions > New repository secret)

1. AWS_ACCESS_KEY_ID
   ${ACCESS_KEY_ID}

2. AWS_SECRET_ACCESS_KEY
   ${SECRET_ACCESS_KEY}

3. AWS_S3_BUCKET
   student.luzqr.com

4. AWS_CLOUDFRONT_DISTRIBUTION_ID
   (You'll get this after creating CloudFront distribution)
EOF

echo -e "${GREEN}Credentials saved to: /tmp/github-secrets.txt${NC}"
echo -e "${YELLOW}Remember to delete this file after adding to GitHub!${NC}"
echo ""

echo "Next steps:"
echo "1. Go to GitHub: https://github.com/YOUR_USERNAME/ldcquinta/settings/secrets/actions"
echo "2. Add the secrets shown above"
echo "3. Continue with CloudFront setup"
echo ""
echo -e "${GREEN}📚 See DEPLOYMENT.md for next steps${NC}"

