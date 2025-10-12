.PHONY: open chrome dev dashboard help setup-aws setup-iam deploy

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "Development:"
	@echo "  make open      - Open index.html (landing page) in Google Chrome"
	@echo "  make chrome    - Same as 'make open'"
	@echo "  make dev       - Open in Chrome (alias)"
	@echo "  make dashboard - Open dashboard.html (checklist) in Google Chrome"
	@echo ""
	@echo "Deployment:"
	@echo "  make setup-aws - Run AWS infrastructure setup (S3)"
	@echo "  make setup-iam - Setup IAM user for GitHub Actions"
	@echo "  make deploy    - Deploy to S3 (requires CLOUDFRONT_DISTRIBUTION_ID env var)"
	@echo ""

# Open in Chrome (default browser command)
open: chrome

# Open specifically in Google Chrome (landing page)
chrome:
	@echo "Opening landing page in Google Chrome..."
	@open -a "Google Chrome" index.html

# Alias for development
dev: chrome

# Open the dashboard/checklist page
dashboard:
	@echo "Opening dashboard in Google Chrome..."
	@open -a "Google Chrome" dashboard.html

# Setup AWS infrastructure
setup-aws:
	@echo "🚀 Setting up AWS infrastructure..."
	@./infrastructure/simple-setup.sh

# Setup IAM user for GitHub Actions
setup-iam:
	@echo "🔐 Setting up IAM user..."
	@./infrastructure/setup-iam-user.sh

# Deploy to AWS
deploy:
	@echo "📤 Deploying to AWS..."
	@./infrastructure/deploy.sh

