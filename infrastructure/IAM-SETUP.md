# 🔐 IAM User Setup for GitHub Actions

## Quick Setup (Automated)

### Option 1: Use the Setup Script (Recommended)

```bash
# Make script executable
chmod +x infrastructure/setup-iam-user.sh

# Run the script
./infrastructure/setup-iam-user.sh
```

This will:
1. ✅ Create IAM user: `ldcquinta-github-actions`
2. ✅ Create a minimal permissions policy
3. ✅ Attach the policy to the user
4. ✅ Generate access keys
5. ✅ Display credentials for GitHub

---

## Manual Setup (Step-by-Step)

### Step 1: Create IAM User

```bash
# Create the user
aws iam create-user --user-name ldcquinta-github-actions

# Verify user created
aws iam get-user --user-name ldcquinta-github-actions
```

**Or via AWS Console:**
1. Go to [IAM Users](https://console.aws.amazon.com/iam/home#/users)
2. Click "Add users"
3. Username: `ldcquinta-github-actions`
4. Access type: ✅ Programmatic access
5. Click "Next: Permissions"

---

### Step 2: Create Custom Policy

Create a file `deployment-policy.json`:

```json
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
```

Then create the policy:

```bash
aws iam create-policy \
  --policy-name LDCQuintaDeploymentPolicy \
  --policy-document file://deployment-policy.json \
  --description "Permissions for LDC Quinta GitHub Actions deployment"
```

**Or via AWS Console:**
1. Go to [IAM Policies](https://console.aws.amazon.com/iam/home#/policies)
2. Click "Create policy"
3. Click "JSON" tab
4. Paste the policy above
5. Name: `LDCQuintaDeploymentPolicy`
6. Click "Create policy"

---

### Step 3: Attach Policy to User

```bash
# Get your account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Attach the policy
aws iam attach-user-policy \
  --user-name ldcquinta-github-actions \
  --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/LDCQuintaDeploymentPolicy
```

**Or via AWS Console:**
1. Go to user: `ldcquinta-github-actions`
2. Click "Add permissions"
3. Click "Attach policies directly"
4. Search for `LDCQuintaDeploymentPolicy`
5. Select it and click "Next" then "Add permissions"

---

### Step 4: Create Access Keys

```bash
# Create access key
aws iam create-access-key --user-name ldcquinta-github-actions

# Output will show:
# - AccessKeyId
# - SecretAccessKey
# ⚠️ SAVE THESE - You can't retrieve the secret key again!
```

**Or via AWS Console:**
1. Go to user: `ldcquinta-github-actions`
2. Click "Security credentials" tab
3. Scroll to "Access keys"
4. Click "Create access key"
5. Choose "Application running outside AWS"
6. Click "Next" then "Create access key"
7. **⚠️ Download or copy both keys NOW!**

---

## Step 5: Add Secrets to GitHub

Go to your GitHub repository:
`https://github.com/YOUR_USERNAME/ldcquinta/settings/secrets/actions`

Click "New repository secret" and add these **4 secrets**:

### 1. AWS_ACCESS_KEY_ID
```
AKIAIOSFODNN7EXAMPLE
```
(Your actual access key from Step 4)

### 2. AWS_SECRET_ACCESS_KEY
```
wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```
(Your actual secret key from Step 4)

### 3. AWS_S3_BUCKET
```
student.luzqr.com
```

### 4. AWS_CLOUDFRONT_DISTRIBUTION_ID
```
E28QBBU83SB043
```
(You already have this from your DEPLOYMENT.md)

---

## Verify Setup

### Test the IAM User

```bash
# Configure AWS CLI with the new credentials temporarily
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY

# Test S3 access
aws s3 ls s3://student.luzqr.com

# Test CloudFront access
aws cloudfront list-distributions

# If both work, you're good to go!
```

### Test GitHub Actions

1. Make a small change to your site
2. Commit and push:
   ```bash
   git add .
   git commit -m "Test deployment"
   git push origin main
   ```
3. Go to GitHub Actions tab
4. Watch the deployment run
5. Check your site: https://student.luzqr.com

---

## Security Best Practices

### ✅ What This User CAN Do
- Upload/delete files in `student.luzqr.com` S3 bucket
- Invalidate CloudFront cache
- List CloudFront distributions

### ❌ What This User CANNOT Do
- Create/delete S3 buckets
- Create/delete CloudFront distributions
- Access other AWS resources
- Modify IAM users/policies
- Incur unexpected costs

### 🔒 Additional Security

#### 1. Add MFA to Your Main AWS Account
```bash
# Enable MFA on your root account
# Go to: https://console.aws.amazon.com/iam/home#/security_credentials
```

#### 2. Rotate Access Keys Regularly
```bash
# List current keys
aws iam list-access-keys --user-name ldcquinta-github-actions

# Create new key, update GitHub, then delete old key
aws iam delete-access-key \
  --user-name ldcquinta-github-actions \
  --access-key-id OLD_KEY_ID
```

#### 3. Monitor Usage
```bash
# Check last access time
aws iam get-access-key-last-used --access-key-id YOUR_KEY
```

#### 4. Enable CloudTrail (Optional)
Tracks all API calls for auditing:
```bash
aws cloudtrail create-trail \
  --name ldcquinta-trail \
  --s3-bucket-name your-cloudtrail-bucket
```

---

## Troubleshooting

### "Access Denied" errors in GitHub Actions

**Check 1: Verify secrets are set**
- Go to GitHub repo settings
- Check all 4 secrets exist
- No extra spaces or newlines

**Check 2: Verify policy is attached**
```bash
aws iam list-attached-user-policies --user-name ldcquinta-github-actions
```

**Check 3: Test credentials locally**
```bash
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
aws s3 ls s3://student.luzqr.com
```

### "Policy is not valid JSON"

Make sure:
- No trailing commas
- All quotes are straight quotes (not curly)
- Valid JSON structure

Test with:
```bash
cat deployment-policy.json | jq .
```

### "User already exists"

If you need to start over:
```bash
# Detach all policies
aws iam list-attached-user-policies --user-name ldcquinta-github-actions
aws iam detach-user-policy --user-name ldcquinta-github-actions --policy-arn POLICY_ARN

# Delete access keys
aws iam list-access-keys --user-name ldcquinta-github-actions
aws iam delete-access-key --user-name ldcquinta-github-actions --access-key-id KEY_ID

# Delete user
aws iam delete-user --user-name ldcquinta-github-actions

# Then run setup again
```

---

## Alternative: Use AWS Managed Policies (Less Secure)

If you want simpler setup (but more permissions):

```bash
# Attach managed policies
aws iam attach-user-policy \
  --user-name ldcquinta-github-actions \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-user-policy \
  --user-name ldcquinta-github-actions \
  --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess
```

⚠️ **Warning:** These give broader permissions than needed.

---

## Cost Impact

**IAM User:** FREE ✨
**API Calls:** FREE (within free tier limits)
**CloudTrail (optional):** ~$2/month if enabled

---

## Quick Reference

```bash
# View user details
aws iam get-user --user-name ldcquinta-github-actions

# List attached policies
aws iam list-attached-user-policies --user-name ldcquinta-github-actions

# List access keys
aws iam list-access-keys --user-name ldcquinta-github-actions

# Check key last used
aws iam get-access-key-last-used --access-key-id YOUR_KEY_ID

# Rotate keys
./infrastructure/setup-iam-user.sh
```

---

## Summary

After completing this setup:

✅ IAM user created with minimal permissions  
✅ Access keys generated  
✅ GitHub secrets configured  
✅ Ready for automatic deployments  

Every push to `main` branch will now automatically deploy to:
### **https://student.luzqr.com** 🚀

