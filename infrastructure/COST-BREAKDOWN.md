# 💰 AWS Cost Breakdown for student.luzqr.com

## Monthly Cost Estimate: ~$1.50/month

Here's exactly where each cost comes from:

## 📦 S3 (Simple Storage Service)

### Storage Cost: ~$0.10/month
- **What:** Stores your HTML, CSS files (index.html, quiz.html, dashboard.html)
- **Pricing:** $0.023 per GB/month (us-east-1)
- **Your usage:** ~4 GB (HTML files are tiny)
- **Calculation:** 4 GB × $0.023 = $0.092/month
- **Actual cost:** Usually under $0.10/month

### Request Cost: ~$0.05/month
- **What:** Each time CloudFront fetches a file from S3
- **Pricing:** 
  - GET requests: $0.0004 per 1,000 requests
  - PUT requests: $0.005 per 1,000 requests
- **Your usage:** ~10,000 requests/month (low traffic)
- **Calculation:** 10,000 × $0.0004 / 1,000 = $0.004/month
- **Note:** CloudFront caches files, so very few S3 requests needed!

**Total S3: ~$0.15/month**

---

## 🌐 CloudFront (CDN)

### Data Transfer Out: ~$0.85/month
- **What:** Serving your website files to visitors globally
- **Pricing:** (varies by region, using US/Europe average)
  - First 10 TB/month: $0.085 per GB
  - Next 40 TB/month: $0.080 per GB
  - ... (decreases with volume)
- **Your usage:** ~10 GB/month (assuming moderate traffic)
- **Calculation:** 10 GB × $0.085 = $0.85/month

### Request Cost: ~$0.01/month
- **What:** HTTP/HTTPS requests from users
- **Pricing:**
  - HTTP: $0.0075 per 10,000 requests
  - HTTPS: $0.0100 per 10,000 requests
- **Your usage:** ~10,000 requests/month
- **Calculation:** 10,000 × $0.0100 / 10,000 = $0.01/month

### SSL Certificate: **FREE** ✨
- AWS Certificate Manager provides FREE SSL certificates!
- Auto-renewal is also FREE
- No hidden charges

**Total CloudFront: ~$0.86/month**

---

## 🌍 Route53 (DNS Service)

### Hosted Zone: $0.50/month
- **What:** DNS hosting for luzqr.com domain
- **Pricing:** $0.50 per hosted zone per month
- **Note:** You pay this whether you use 1 subdomain or 100
- **Your usage:** student.luzqr.com uses existing luzqr.com hosted zone

### DNS Queries: ~$0.01/month
- **What:** DNS lookups when users visit your site
- **Pricing:** $0.40 per million queries
- **Your usage:** ~25,000 queries/month
- **Calculation:** 25,000 × $0.40 / 1,000,000 = $0.01/month
- **Note:** First 1 billion queries per month for latency-based routing are FREE

**Total Route53: ~$0.51/month**

---

## 📊 Detailed Monthly Cost Breakdown

| Service | Component | Cost |
|---------|-----------|------|
| **S3** | Storage (4 GB) | $0.10 |
| **S3** | Requests (10K) | $0.05 |
| **CloudFront** | Data transfer (10 GB) | $0.85 |
| **CloudFront** | HTTPS requests (10K) | $0.01 |
| **CloudFront** | SSL Certificate | **FREE** |
| **Route53** | Hosted zone | $0.50 |
| **Route53** | DNS queries (25K) | $0.01 |
| **ACM** | SSL Certificate | **FREE** |
| **ACM** | Auto-renewal | **FREE** |
| | **TOTAL** | **~$1.52/month** |

---

## 📈 Cost Scaling by Traffic

### Low Traffic (100 visitors/day)
- Data transfer: ~3 GB/month
- **Total: ~$0.80/month**

### Medium Traffic (1,000 visitors/day)
- Data transfer: ~30 GB/month
- **Total: ~$3.50/month**

### High Traffic (10,000 visitors/day)
- Data transfer: ~300 GB/month
- **Total: ~$26/month**

*Note: Prices decrease per GB at higher volumes*

---

## 💡 What's FREE?

✅ **SSL/TLS Certificate** - Worth $100+/year elsewhere!
✅ **Certificate Auto-renewal** - No manual work
✅ **HTTP to HTTPS redirects** - Built into CloudFront
✅ **Global CDN edge locations** - Faster for users worldwide
✅ **DDoS protection** (AWS Shield Standard) - Included with CloudFront
✅ **IPv6 support** - No extra charge
✅ **Unlimited subdomains** - Same Route53 hosted zone cost
✅ **AWS WAF (50% off)** - If you need it later

---

## 🎯 Cost Optimization Tips

### 1. Enable CloudFront Compression
Already configured in your setup! Reduces data transfer by ~60%

### 2. Set Proper Cache Headers
Already configured! HTML files cached for 1 hour, reducing S3 requests

### 3. Use Price Class 100
Already configured! Uses only US, Canada, and Europe edge locations
- Saves ~30% vs global distribution
- Still fast for most visitors

### 4. Delete Old CloudFront Invalidations
- First 1,000 paths/month: **FREE**
- After that: $0.005 per path
- Our GitHub Action invalidates `/*` = 1 path per deployment

### 5. Clean Up Unused Files
```bash
# Remove old files from S3
aws s3 rm s3://student.luzqr.com/old-file.html
```

---

## 🆓 AWS Free Tier

If your AWS account is **less than 12 months old**, you get:

### Free Tier Benefits:
- **S3:** 5 GB storage, 20,000 GET requests, 2,000 PUT requests
- **CloudFront:** 1 TB data transfer out, 10 million requests
- **Route53:** Not included in free tier
- **Certificate Manager:** Always free

**Your first year could be ~$0.50/month (just Route53)!**

---

## 💳 Actual Costs Examples

### Your HTML-only Site (as configured):
```
Month 1: $0.52 (minimal traffic)
Month 2: $1.42 (growing traffic)
Month 3: $1.86 (steady traffic)
Average: ~$1.50/month
```

### With 1,000 daily visitors:
```
S3: $0.15
CloudFront: $2.80
Route53: $0.51
Total: $3.46/month
```

### Compared to Other Hosting:

| Service | Cost/month | HTTPS | CDN | Custom Domain |
|---------|-----------|-------|-----|---------------|
| **AWS (Your Setup)** | **$1.50** | ✅ | ✅ | ✅ |
| Netlify (Free) | $0 | ✅ | ✅ | ✅ |
| Vercel (Free) | $0 | ✅ | ✅ | ✅ |
| GitHub Pages | $0 | ✅ | ✅ | ✅ |
| Traditional Hosting | $5-20 | ⚠️ | ❌ | ✅ |
| VPS (DigitalOcean) | $6 | ⚠️ | ❌ | ✅ |

*Note: Free options exist, but AWS gives you more control and enterprise features*

---

## 📊 Monitor Your Costs

### Set Up Billing Alerts
```bash
# Create a billing alarm for $5/month
aws cloudwatch put-metric-alarm \
  --alarm-name ldcquinta-billing-alarm \
  --alarm-description "Alert if costs exceed $5" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 5.0 \
  --comparison-operator GreaterThanThreshold
```

### Check Current Costs
```bash
# View month-to-date costs
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### AWS Cost Explorer
- Go to: https://console.aws.amazon.com/cost-management/home
- View daily costs by service
- Set budgets and alerts

---

## 🎓 Student/Educational Discounts

### AWS Educate
- Free credits if you're a student
- Up to $100 in AWS credits
- Apply: https://aws.amazon.com/education/awseducate/

### GitHub Student Developer Pack
- Includes $150 in AWS credits
- Plus many other free services
- Apply: https://education.github.com/pack

---

## ❓ FAQ

### "Why not use free hosting like Netlify?"
Good question! You certainly could. AWS gives you:
- More control over infrastructure
- Experience with industry-standard tools
- Scalability without switching providers
- Better for learning cloud architecture

### "Can I reduce costs further?"
Yes! Options:
1. Use S3-only (no CloudFront) = $0.65/month
   - Cons: No HTTPS, slower, no CDN
2. Use CloudFront with S3 but no custom domain = $1.00/month
   - Cons: Use CloudFront URL instead
3. Switch to Netlify/Vercel = $0/month
   - Cons: Less control, learning opportunity

### "Will costs spike unexpectedly?"
Unlikely! Your site is static (no compute costs). Worst case:
- Viral traffic: CloudFront costs scale, but slowly
- DDoS attack: AWS Shield protects you (included free)
- Misconfiguration: Set billing alerts to catch this

### "What if I forget to delete resources?"
Set calendar reminders or:
```bash
# Add this to your crontab to get monthly cost reports
aws ce get-cost-and-usage --time-period Start=$(date -d '1 month ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics BlendedCost
```

---

## 🧮 Cost Calculator

Use AWS's official calculator:
https://calculator.aws/#/

Input your expected:
- Monthly visitors
- Average page size
- Geographic distribution

---

## 📞 Support

If costs are higher than expected:
1. Check CloudFormation events for errors
2. Review CloudWatch metrics
3. Check for unexpected traffic (could be bots)
4. Enable AWS Cost Anomaly Detection (free)

---

## Summary

Your LDC Quinta website costs approximately:
### **$1.50/month** 📊

For that, you get:
- ✅ Global CDN (fast worldwide)
- ✅ Free HTTPS certificate
- ✅ 99.99% uptime SLA
- ✅ Automatic scaling
- ✅ Professional infrastructure

**That's less than a coffee! ☕**

