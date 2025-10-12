#!/bin/bash

# Manual deployment script for LDC Quinta
# Use this to deploy manually without GitHub Actions

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BUCKET_NAME="student.luzqr.com"
REGION="us-east-1"

echo -e "${GREEN}🚀 Deploying LDC Quinta to S3...${NC}"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured."
    exit 1
fi

# Sync files to S3
echo -e "${YELLOW}📤 Syncing files to S3...${NC}"
cd "$(dirname "$0")/.."
aws s3 sync . "s3://${BUCKET_NAME}" \
    --exclude ".git/*" \
    --exclude ".github/*" \
    --exclude "infrastructure/*" \
    --exclude "README.md" \
    --exclude "Makefile" \
    --exclude ".gitignore" \
    --exclude "*.sh" \
    --delete \
    --cache-control "public, max-age=86400"

# Set HTML-specific cache headers
echo -e "${YELLOW}⚙️  Setting cache headers...${NC}"
for file in index.html quiz.html dashboard.html; do
    if aws s3 ls "s3://${BUCKET_NAME}/${file}" &> /dev/null; then
        aws s3 cp "s3://${BUCKET_NAME}/${file}" \
            "s3://${BUCKET_NAME}/${file}" \
            --metadata-directive REPLACE \
            --cache-control "public, max-age=3600" \
            --content-type "text/html"
    fi
done

# Invalidate CloudFront if distribution ID is provided
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo -e "${YELLOW}🔄 Invalidating CloudFront cache...${NC}"
    aws cloudfront create-invalidation \
        --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
        --paths "/*"
else
    echo -e "${YELLOW}⚠️  CLOUDFRONT_DISTRIBUTION_ID not set, skipping cache invalidation${NC}"
    echo "Set it with: export CLOUDFRONT_DISTRIBUTION_ID=YOUR_ID"
fi

echo ""
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo -e "${GREEN}🌐 Website URL: https://student.luzqr.com${NC}"

