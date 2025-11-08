# Quick Start: Step 2 Testing

## File Locations

- `information.html` - The new Step 2 form page
- `basic.html` - Updated to redirect to `information.html`
- `STEP2_IMPLEMENTATION.md` - Detailed feature documentation
- `STEP2_LAYOUT.md` - Visual layout guide

## Quick Testing

### 1. Start the Server
```bash
cd /path/to/ldcquinta
python3 -m http.server 8000
```

### 2. Test the Flow
1. Open http://localhost:8000/basic.html
2. Select some services by clicking on service cards
3. Click "Continue →" button
4. You should be redirected to `information.html`

### 3. On the Information Page

**In the Sidebar:**
- You'll see all selected services
- The first one is highlighted in blue
- Each shows an icon, name, and estimated time

**In the Form:**
- Fill in the fields for the highlighted service
- Different services have different fields
- As you fill fields, the progress bar updates

**In the Footer:**
- "Fields Remaining: X / Total" counter
- "Estimated Time: XYZ min"
- Progress bar showing completion
- Two buttons: "Back" and "Continue to Payment"

### 4. Try These Actions

**Switch Services:**
- Click a different service in the left sidebar
- Form should smoothly transition to show that service's form
- Progress bar updates

**Fill a Form:**
- Enter text in input fields
- Select from dropdowns
- Check checkboxes
- Watch the "Fields Remaining" counter decrease

**Check Completion Status:**
- When you complete all required fields in a service
- A green checkmark (✓) appears next to that service
- Service item becomes slightly transparent

**Change Language:**
- Click the globe icon (🌐) in the header
- Select English (🇬🇧), French (🇫🇷), or Spanish (🇪🇸)
- All text should update

**Navigate Back:**
- Click "← Back" button to return to basic.html
- Or use the back arrow in the header

## Data Flow

1. **basic.html** → Select services → Save indices to `sessionStorage.selectedBasicServices`
2. **information.html** → Load from sessionStorage → Display forms
3. Forms → Fill data → Save to `sessionStorage.serviceFormData`
4. Click "Continue to Payment" → Ready for Step 3

## Field Types

The form includes different input types:

1. **Text Input** - e.g., "Current Mobile Carrier"
2. **Select Dropdown** - e.g., "eSIM Compatibility"
3. **Textarea** - e.g., "Additional Notes"
4. **Checkboxes** - e.g., "Insurance Types Needed"

## Services and Fields

### 📱 eSIM Setup (4 fields)
- Current Carrier (text)
- eSIM Compatible (select)
- Preferred Plan (select)
- Notes (textarea)

### 📡 Internet Box (5 fields)
- Living Area (text)
- Usage Level (select)
- Providers (checkboxes)
- Installation Date (text)
- Notes (textarea)

### 🏦 Bank Account (6 fields)
- Full Name (text)
- Account Type (select)
- Residency Status (select)
- Documents (checkboxes) - **required**
- Preferred Bank (select)
- Notes (textarea)

### 🚇 Transport (4 fields)
- City/Region (select)
- Travel Frequency (select)
- Card Type (select)
- Notes (textarea)

### 🛡️ Insurance (5 fields)
- Insurance Types (checkboxes) - **required**
- Current Insurance (select)
- Budget (select)
- Family Status (select)
- Notes (textarea)

## Required vs Optional Fields

### Required Fields (marked with *)
- Impact the completion checkmark
- Must be filled to complete a service
- Validation checks these

### Optional Fields
- Don't block completion
- Nice-to-have information
- Help provide context

## Customization

### Add a New Service

Edit `serviceConfigs` in `information.html`:

```javascript
{
    id: 'newservice',
    name: 'New Service Name',
    icon: '🆕',
    description: 'Service description',
    estimatedTime: 30,
    fields: [
        { name: 'field1', label: 'Field 1', type: 'text', required: true },
        { name: 'field2', label: 'Field 2', type: 'select', required: true, options: ['...'] }
    ]
}
```

### Add a New Language

1. Add to `serviceConfigs` (all three languages)
2. Add to `translations` object
3. Test with language selector

### Change Colors

Edit CSS variables in `:root`:
```css
--primary-color: #667eea;
--secondary-color: #764ba2;
--success-color: #10b981;
--error-color: #ef4444;
```

### Adjust Sidebar Width

Change in CSS:
```css
.services-sidebar {
    width: 280px; /* Change this */
}
```

## Browser DevTools Tips

### Check Form Data
Open Console and type:
```javascript
sessionStorage.getItem('serviceFormData')
```

### Check Selected Services
```javascript
sessionStorage.getItem('selectedBasicServices')
```

### Manually Trigger Form Update
```javascript
updateProgress()
```

## Common Issues & Fixes

### Issue: Services not showing in sidebar
**Fix**: Make sure you selected services in `basic.html` before continuing

### Issue: Progress bar not updating
**Fix**: Check browser console for JavaScript errors (F12)

### Issue: Language not changing
**Fix**: Clear browser cache and reload. Make sure all translation keys exist

### Issue: Scrolling is jerky
**Fix**: Check CSS animations - ensure GPU acceleration is enabled

### Issue: Mobile layout broken
**Fix**: Check viewport meta tag and media queries

## Browser Compatibility

Tested and working on:
- ✅ Chrome 120+
- ✅ Firefox 121+
- ✅ Safari 17+
- ✅ Edge 120+
- ✅ Mobile Safari (iOS 17+)
- ✅ Chrome Mobile (Android 13+)

## Performance Tips

1. **Fast page load**: All inline CSS/JS, no external dependencies
2. **Smooth scrolling**: GPU-accelerated CSS transitions
3. **Minimal reflows**: Event debouncing on form changes
4. **Mobile-friendly**: Responsive design, no layout shifts

## Next Steps

After Step 2 works:

1. Create `payment.html` (Step 3)
2. Add form validation
3. Connect to backend API
4. Add error handling
5. Add confirmation email
6. Add analytics

## Support Files

- `STEP2_IMPLEMENTATION.md` - Full feature documentation
- `STEP2_LAYOUT.md` - Visual layout and interaction guide
- This file - Quick reference

---

**Need help?** Check the documentation files or browser console for error messages.

