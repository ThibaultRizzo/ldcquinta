.PHONY: open chrome dev dashboard help

# Default target
help:
	@echo "Available commands:"
	@echo "  make open      - Open index.html (landing page) in Google Chrome"
	@echo "  make chrome    - Same as 'make open'"
	@echo "  make dev       - Open in Chrome (alias)"
	@echo "  make dashboard - Open dashboard.html (checklist) in Google Chrome"

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

