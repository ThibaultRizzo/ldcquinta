# 🔒 HTTPS Setup for student.luzqr.com

## Quick Reference

Your website will be served with **full HTTPS encryption** using:
- AWS Certificate Manager (ACM) - **FREE SSL certificate**
- CloudFront CDN - Handles SSL termination
- Automatic HTTP → HTTPS redirect
- TLS 1.2+ encryption

## Why HTTPS?

✅ **Secure** - Encrypts data between users and your site  
✅ **Trust** - Shows padlock icon in browsers  
✅ **SEO** - Google ranks HTTPS sites higher  
✅ **Modern** - Required for many browser features  
✅ **Free** - AWS provides the certificate at no cost  

## Architecture

```
User's Browser
    ↓ (HTTPS - Encrypted)
CloudFront CDN (with SSL Certificate)
    ↓ (HTTP or HTTPS)
S3 Static Website
    ↓
Your HTML files
```

## SSL Certificate Setup

### 1. Request Certificate (MUST be in us-east-1)

```bash
aws acm request-certificate \
  --domain-name student.luzqr.com \
  --validation-method DNS \
  --region us-east-1
```

**Important:** CloudFront requires certificates to be in **us-east-1** region!

### 2. Validate via DNS

**Easiest method (Automatic):**
1. Go to [ACM Console](https://console.aws.amazon.com/acm/home?region=us-east-1)
2. Click your certificate
3. Click "Create records in Route 53"
4. Wait 5-10 minutes

**Manual method:**
```bash
# Get validation record
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[0].ResourceRecord'

# Add the CNAME record to Route53 manually
```

### 3. Verify Certificate Status

```bash
aws acm describe-certificate \
  --certificate-arn YOUR_CERT_ARN \
  --region us-east-1 \
  --query 'Certificate.Status' \
  --output text
```

Should return: `ISSUED`

## CloudFront HTTPS Configuration

Your CloudFront distribution is configured with:

```yaml
ViewerProtocolPolicy: redirect-to-https  # Redirects HTTP to HTTPS
SSLSupportMethod: sni-only              # Modern SSL delivery
MinimumProtocolVersion: TLSv1.2_2021    # Strong encryption only
```

This means:
- ✅ All HTTP requests automatically redirect to HTTPS
- ✅ Only modern, secure TLS versions allowed (1.2+)
- ✅ No additional cost for SSL
- ✅ Compatible with 99.9% of browsers

## Testing HTTPS

### Test HTTP Redirect
```bash
curl -I http://student.luzqr.com
# Should see: 301 or 302 redirect to https://
```

### Test HTTPS
```bash
curl -I https://student.luzqr.com
# Should see: 200 OK
```

### Test SSL Certificate
```bash
openssl s_client -connect student.luzqr.com:443 -servername student.luzqr.com < /dev/null 2>&1 | grep -A 2 "Certificate chain"
```

### Browser Test
Open: https://student.luzqr.com
- Should see 🔒 padlock icon
- Click padlock → Connection is secure
- Certificate issued by: Amazon

### SSL Labs Test (Optional)
Visit: https://www.ssllabs.com/ssltest/analyze.html?d=student.luzqr.com
- Should get an **A** rating

## Certificate Auto-Renewal

✅ AWS automatically renews your certificate before expiration  
✅ No action required from you  
✅ Renewal happens 60 days before expiration  
✅ Uses the same DNS validation record  

## Troubleshooting

### "Certificate not validating"
- Verify CNAME record exists in Route53 for luzqr.com
- Wait up to 30 minutes for DNS propagation
- Check the record name matches exactly (including the dot at the end)

### "NET::ERR_CERT_COMMON_NAME_INVALID"
- Certificate doesn't match domain
- Verify certificate is for `student.luzqr.com`
- Check CloudFront alternate domain names (CNAMEs)

### "This site can't provide a secure connection"
- CloudFront not using the certificate
- Verify certificate ARN in CloudFront distribution
- Ensure certificate status is `ISSUED`

### "Mixed content" warnings
- Some resources loaded over HTTP instead of HTTPS
- All links should use relative paths or HTTPS URLs
- Check browser console for mixed content errors

## Security Headers (Optional Enhancement)

Add these headers in CloudFront for extra security:

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
```

## Cost

**SSL Certificate:** FREE ✨  
**CloudFront HTTPS:** No additional charge  
**Total Extra Cost for HTTPS:** $0.00  

## Compliance

Your HTTPS setup meets:
- ✅ PCI DSS requirements
- ✅ GDPR data protection standards
- ✅ SOC 2 compliance
- ✅ HIPAA eligible (with AWS BAA)

## Resources

- [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
- [CloudFront SSL/TLS](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-https.html)
- [SSL Labs Test](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL Config](https://ssl-config.mozilla.org/)

## Quick Commands

```bash
# Request certificate
aws acm request-certificate --domain-name student.luzqr.com --validation-method DNS --region us-east-1

# Check certificate status
aws acm list-certificates --region us-east-1

# Test HTTPS
curl -I https://student.luzqr.com

# Test SSL certificate details
echo | openssl s_client -servername student.luzqr.com -connect student.luzqr.com:443 2>/dev/null | openssl x509 -noout -dates

# Check DNS resolution
dig student.luzqr.com
```

---

🎉 **Your site is now secured with HTTPS!**

All traffic is encrypted, users see the padlock icon, and you get better SEO rankings!

