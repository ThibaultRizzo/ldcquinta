# ⚡ Quick Start Guide - LDC Quinta Deployment

## 🎯 Goal
Deploy your website to **https://student.luzqr.com** in ~30 minutes

## ✅ Prerequisites
- [ ] AWS account
- [ ] AWS CLI installed and configured
- [ ] Domain `luzqr.com` in Route53
- [ ] GitHub repository created

---

## 📝 5-Step Deployment

### Step 1: Setup S3 Bucket (5 minutes)
```bash
make setup-aws
```

✅ Creates S3 bucket and uploads files

---

### Step 2: Request SSL Certificate (5 minutes)
```bash
aws acm request-certificate \
  --domain-name student.luzqr.com \
  --validation-method DNS \
  --region us-east-1
```

Then validate it:
1. Go to [ACM Console](https://console.aws.amazon.com/acm/home?region=us-east-1)
2. Click your certificate
3. Click "Create records in Route 53"
4. Wait ~5 minutes for validation

---

### Step 3: Create CloudFront Distribution (10 minutes)

Go to [CloudFront Console](https://console.aws.amazon.com/cloudfront/v3/home#/distributions/create)

**Quick settings:**
- Origin domain: `student.luzqr.com.s3-website-us-east-1.amazonaws.com`
- Viewer protocol policy: `Redirect HTTP to HTTPS`
- Alternate domain name (CNAME): `student.luzqr.com`
- Custom SSL certificate: Select your certificate
- Default root object: `index.html`

Click "Create distribution"

**Save the Distribution ID!** (e.g., `E28QBBU83SB043`)

---

### Step 4: Update DNS (2 minutes)

In CloudFront, copy the distribution domain name (e.g., `d1ksry4j843x26.cloudfront.net`)

```bash
# Get hosted zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
  --dns-name luzqr.com \
  --query 'HostedZones[0].Id' \
  --output text | cut -d'/' -f3)

# Create DNS record
cat > /tmp/route53.json << EOF
{
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "student.luzqr.com",
      "Type": "A",
      "AliasTarget": {
        "HostedZoneId": "Z2FDTNDATAQYW2",
        "DNSName": "YOUR_CLOUDFRONT_DOMAIN",
        "EvaluateTargetHealth": false
      }
    }
  }]
}
EOF

# Update YOUR_CLOUDFRONT_DOMAIN in the file, then:
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file:///tmp/route53.json
```

---

### Step 5: Setup GitHub Actions (5 minutes)

#### A. Create IAM User
```bash
make setup-iam
```

This will display:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

#### B. Add GitHub Secrets

Go to: `https://github.com/YOUR_USERNAME/ldcquinta/settings/secrets/actions`

Add 4 secrets:
1. `AWS_ACCESS_KEY_ID` - From previous step
2. `AWS_SECRET_ACCESS_KEY` - From previous step
3. `AWS_S3_BUCKET` - `student.luzqr.com`
4. `AWS_CLOUDFRONT_DISTRIBUTION_ID` - From Step 3

#### C. Push to GitHub
```bash
git add .
git commit -m "Add AWS deployment configuration"
git push origin main
```

---

## 🎉 Done!

Your site is now live at: **https://student.luzqr.com**

Check deployment status:
- GitHub: Actions tab
- AWS: CloudFront console

---

## 🔍 Quick Checks

### Is S3 working?
```bash
aws s3 ls s3://student.luzqr.com/
```

### Is certificate validated?
```bash
aws acm list-certificates --region us-east-1
```
Look for Status: `ISSUED`

### Is CloudFront deployed?
```bash
aws cloudfront list-distributions \
  --query 'DistributionList.Items[?Aliases.Items[?@==`student.luzqr.com`]].Status' \
  --output text
```
Should show: `Deployed`

### Is DNS working?
```bash
dig student.luzqr.com
```

### Test the site
```bash
curl -I https://student.luzqr.com
```
Should return: `200 OK`

---

## ⚠️ Troubleshooting

### Certificate not validating
- Wait 10 minutes
- Check Route53 has CNAME record for validation
- Verify CNAME record matches certificate exactly

### CloudFront 404 error
- Check origin domain name ends with `.s3-website-us-east-1.amazonaws.com`
- Verify S3 bucket has public access
- Check S3 website hosting is enabled

### DNS not resolving
- Wait 15-30 minutes for propagation
- Verify Route53 A record points to CloudFront
- Check CloudFront alternate domain names include `student.luzqr.com`

### GitHub Actions failing
- Check all 4 secrets are set
- Verify no extra spaces in secrets
- Check IAM user has correct permissions

---

## 📚 Detailed Documentation

- **Full Guide:** [DEPLOYMENT.md](DEPLOYMENT.md)
- **IAM Setup:** [IAM-SETUP.md](IAM-SETUP.md)
- **HTTPS Details:** [HTTPS-SETUP.md](HTTPS-SETUP.md)
- **Cost Info:** [COST-BREAKDOWN.md](COST-BREAKDOWN.md)

---

## 🚀 Next Deployment

Every push to `main` branch automatically deploys!

```bash
# Edit your files
vim index.html

# Commit and push
git add .
git commit -m "Update homepage"
git push origin main

# Watch deployment in GitHub Actions tab
```

Site updates in ~2 minutes! 🎊

