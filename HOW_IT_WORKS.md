# How It Works - Step 2 Scroll-Based Highlighting

## Quick Overview

The Step 2 page now uses **scroll-based sidebar highlighting** - as you scroll through the form, the sidebar automatically highlights which service you're currently viewing.

---

## 🎯 Core Mechanic

```
User scrolls through form
        ↓
Scroll event detected (debounced at 50ms)
        ↓
updateActiveServiceOnScroll() runs
        ↓
Calculates which form is closest to viewport top
        ↓
Updates sidebar highlight to match
        ↓
Real-time sync between scroll position and sidebar
```

---

## 🔍 How Scroll Detection Works

### 1. Get Container & Sections
```javascript
const container = document.getElementById('formScrollable');
const sections = document.querySelectorAll('.form-section');
```

### 2. Calculate Distances
```javascript
sections.forEach((section, index) => {
    const rect = section.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();
    
    // Distance from container top to form top
    const distance = Math.abs(rect.top - containerRect.top);
```

### 3. Find Minimum Distance
```javascript
    if (distance < minDistance) {
        minDistance = distance;
        activeIndex = index;  // This is the visible service
    }
});
```

### 4. Highlight Service
```javascript
document.querySelectorAll('.service-item').forEach((item, i) => {
    item.classList.toggle('active', i === activeIndex);
});
```

---

## 📍 Visual Representation

### Layout
```
┌─────────────────────────────────────┐
│ formScrollable viewport             │ ← Container top
├─────────────────────────────────────┤
│ 📱 Form 1 (distance = ~0px)         │ ← ACTIVE (closest to top)
│ [fields]                            │
├─────────────────────────────────────┤
│ 📡 Form 2 (distance = ~500px)       │
│ [fields]                            │
│ [viewport showing this area ↓]      │
├─────────────────────────────────────┤
│ 🏦 Form 3 (distance = ~1000px)      │
│ [fields]                            │
│ [user scrolled here]                │
├─────────────────────────────────────┤
│ 🚇 Form 4 (distance = ~1500px)      │
│ [fields]                            │
└─────────────────────────────────────┘
```

---

## ⚡ Performance Optimization

### Debouncing
```javascript
let scrollTimeout;

container.addEventListener('scroll', function() {
    clearTimeout(scrollTimeout);           // Cancel previous timer
    scrollTimeout = setTimeout(() => {
        updateActiveServiceOnScroll();      // Only run after 50ms of no scrolling
    }, 50);
});
```

**Why?**
- Scroll events fire MANY times per second (60+ per second)
- Without debouncing = 60+ unnecessary calculations per second
- With debouncing = calculations only when scrolling stops/slows
- Result = smooth performance, no jank

---

## 🎯 Sidebar Highlighting

### Active State
```css
.service-item.active {
    background: linear-gradient(
        135deg, 
        rgba(102, 126, 234, 0.08) 0%, 
        rgba(118, 75, 162, 0.08) 100%
    );
    border-left: 3px solid var(--primary-color);
    padding-left: 13px;
}
```

When a service is in the viewport:
- Light blue background gradient
- 3px blue left border
- Slightly indented (padding adjustment)

---

## 🖱️ Click to Scroll

### Clicking a Service
```javascript
item.onclick = () => scrollToService(index);

function scrollToService(index) {
    const section = document.getElementById(`form-section-${index}`);
    section.scrollIntoView({ behavior: 'smooth', block: 'start' });
}
```

**Result:** Smooth scroll animation to that service's form

---

## 📝 Form Structure

### Continuous Rendering
All forms are rendered at once (not hidden/shown):

```html
<div class="form-scrollable">
    <!-- Form 1 -->
    <div class="form-section" id="form-section-0">
        <div class="form-title">📱 eSIM Setup</div>
        [all fields]
    </div>

    <!-- Separator -->
    <hr style="border-bottom: 2px solid #e0e0e0; margin: 40px 0;">

    <!-- Form 2 -->
    <div class="form-section" id="form-section-1">
        <div class="form-title">📡 Internet Box</div>
        [all fields]
    </div>

    <!-- Form 3, 4, 5... same pattern -->
</div>
```

**Key difference:** No `display: none` on forms - they're all visible in the scroll area

---

## 🔄 Event Flow

### On Page Load
```
DOMContentLoaded
    ↓
loadSelectedServices()      ← Load selected services
    ↓
renderServicesList()        ← Create sidebar items
    ↓
renderForms()              ← Create all form sections
    ↓
setupScrollListener()       ← Attach scroll listener
    ↓
updateActiveServiceOnScroll() ← Initial highlight (Form 1)
```

### On Scroll
```
User scrolls
    ↓
Scroll event fires (multiple times per second)
    ↓
Debounced timer clears/restarts (50ms delay)
    ↓
Timer expires → updateActiveServiceOnScroll() runs
    ↓
Find which form is closest to top
    ↓
Update sidebar highlight
    ↓
User stops scrolling
    ↓
Ready for next scroll
```

### On Language Change
```
User changes language
    ↓
changeLanguage() called
    ↓
Re-render services list
    ↓
Re-render all forms (in new language)
    ↓
setupScrollListener() (re-attach listener)
    ↓
updateActiveServiceOnScroll() (re-highlight)
```

---

## 💾 Data Handling

### During Scroll
Form data is captured in real-time as user fills fields:

```javascript
// Input change event
<input onchange="updateFormData('${fieldId}')">

function updateFormData(fieldId) {
    formData[serviceId][fieldName] = value;
    updateProgress();  // Updates progress bar, field counter
}
```

**Data persists** even while scrolling to different sections

### On Submission
```javascript
function goToPayment() {
    // Save all collected data
    sessionStorage.setItem('serviceFormData', 
        JSON.stringify(formData)
    );
    // Redirect
    window.location.href = 'payment.html';
}
```

---

## 🎨 Visual Flow

### User Journey
```
📱 Start Page
    ↓
Select Services (basic.html)
    ↓
Click "Continue"
    ↓
↓↓↓ INFORMATION PAGE LOADED ↓↓↓
    ↓
See all forms stacked vertically
Service 1 highlighted in sidebar
    ↓
Scroll down through forms
    Sidebar auto-updates as each comes into view
    ↓
Click Service 4 in sidebar
    Page smoothly scrolls to Service 4
    ↓
Fill out all service forms
    Progress bar updates in real-time
    ↓
Click "Continue to Payment"
    ↓
💳 Payment Page (Step 3)
```

---

## 🧪 Testing the Feature

### Test 1: Auto-Highlight
1. Open information.html
2. Service 1 should be highlighted in sidebar
3. Slowly scroll down
4. Watch sidebar highlight change as each form comes into view
5. ✓ Should see smooth highlight transitions

### Test 2: Click Navigation
1. Scroll to middle of page
2. Click Service 1 in sidebar
3. Page should smoothly scroll back to Service 1
4. ✓ Should see smooth scroll animation

### Test 3: Scroll Performance
1. Scroll rapidly up and down
2. Watch for lag or jank
3. ✓ Should be smooth at 60 FPS

### Test 4: Mobile Scroll
1. Open on mobile device
2. Scroll through form vertically
3. Sidebar should update as you scroll
4. ✓ Should feel natural and responsive

---

## 🔧 Key Variables

```javascript
currentServiceIndex     // Which service is currently active
selectedServices        // Array of selected service objects
formData               // Object storing all form data
currentLanguage        // Current language (en/fr/es)
```

---

## 🎯 Intersection Calculation

The key algorithm that makes it work:

```javascript
// For each form section
const rect = section.getBoundingClientRect();           // Position relative to viewport
const containerRect = container.getBoundingClientRect(); // Container position

// Distance from container top to form top
const distance = Math.abs(rect.top - containerRect.top);

// Form with smallest distance = closest to top = most visible
if (distance < minDistance) {
    minDistance = distance;
    activeIndex = index;
}
```

This finds which form is "in view" at the top of the scroll container.

---

## ✨ Summary

**The magic:** As you scroll, JavaScript constantly checks which service form is closest to the viewport top, and updates the sidebar highlight to match.

**The result:** Intuitive, automatic sidebar highlighting that shows exactly where you are in the form.

**The UX:** Natural scrolling interaction with automatic visual feedback about your location.

---

**That's it!** Simple, effective, and provides great user experience. 🚀

