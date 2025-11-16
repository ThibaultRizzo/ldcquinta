/**
 * SHARED.JS - Common utilities across all pages
 * This file eliminates code duplication and provides reusable functions
 */

// ==================== LANGUAGE MANAGEMENT ====================

/**
 * Get current language from localStorage
 * @returns {string} Current language code (en, fr, es)
 */
function getCurrentLanguage() {
    return localStorage.getItem('language') || 'en';
}

/**
 * Set language preference and trigger update
 * @param {string} lang - Language code
 */
function setLanguage(lang) {
    localStorage.setItem('language', lang);
}

/**
 * Toggle language menu visibility
 */
function toggleLanguageMenu() {
    const menu = document.getElementById('languageMenu');
    if (menu) {
        menu.classList.toggle('active');
    }
}

/**
 * Close language menu when clicking outside
 */
document.addEventListener('DOMContentLoaded', function() {
    document.addEventListener('click', function(event) {
        const languageSelector = document.querySelector('.language-selector');
        if (languageSelector && !languageSelector.contains(event.target)) {
            const menu = document.getElementById('languageMenu');
            if (menu) {
                menu.classList.remove('active');
            }
        }
    });
});

// ==================== FORM UTILITIES ====================

/**
 * Get all checked checkboxes for a field
 * @param {string} fieldId - Field identifier
 * @returns {Array<HTMLInputElement>} Array of checked checkbox elements
 */
function getCheckedCheckboxes(fieldId) {
    return Array.from(document.querySelectorAll(`input[name="${fieldId}"]`))
        .filter(cb => cb.checked);
}

/**
 * Get values of all checked checkboxes
 * @param {string} fieldId - Field identifier
 * @returns {Array<string>} Array of checkbox values
 */
function getCheckedCheckboxValues(fieldId) {
    return getCheckedCheckboxes(fieldId).map(cb => cb.value);
}

/**
 * Placeholder values for select dropdowns
 */
const SELECT_PLACEHOLDERS = {
    en: 'Select...',
    fr: 'Sélectionner...',
    es: 'Seleccionar...'
};

/**
 * Check if a value is a select placeholder
 * @param {string} value - Value to check
 * @returns {boolean} True if value is a placeholder
 */
function isSelectPlaceholder(value) {
    return Object.values(SELECT_PLACEHOLDERS).includes(value);
}

/**
 * Check if a form field is filled and valid
 * @param {HTMLElement} element - Form element to check
 * @param {Object} field - Field configuration object
 * @returns {boolean} True if field is valid/filled
 */
function isFieldValid(element, field) {
    if (!element) return false;

    if (field.type === 'checkbox') {
        return getCheckedCheckboxes(element.name || `${field.id}`).length > 0;
    }

    const value = element.value;
    return value && !isSelectPlaceholder(value);
}

// ==================== ERROR HANDLING ====================

/**
 * Show user-friendly error message
 * @param {string} message - Error message to display
 * @param {number} duration - Duration in ms (default 3000)
 */
function showError(message, duration = 3000) {
    // Create error element if it doesn't exist
    let errorEl = document.getElementById('error-message');
    if (!errorEl) {
        errorEl = document.createElement('div');
        errorEl.id = 'error-message';
        errorEl.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #ef4444;
            color: white;
            padding: 12px 20px;
            border-radius: 6px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            max-width: 90%;
            font-weight: 600;
        `;
        document.body.appendChild(errorEl);
    }
    
    errorEl.textContent = message;
    errorEl.style.display = 'block';
    
    setTimeout(() => {
        errorEl.style.display = 'none';
    }, duration);
}

/**
 * Show user-friendly success message
 * @param {string} message - Success message to display
 * @param {number} duration - Duration in ms (default 3000)
 */
function showSuccess(message, duration = 3000) {
    let successEl = document.getElementById('success-message');
    if (!successEl) {
        successEl = document.createElement('div');
        successEl.id = 'success-message';
        successEl.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #10b981;
            color: white;
            padding: 12px 20px;
            border-radius: 6px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            max-width: 90%;
            font-weight: 600;
        `;
        document.body.appendChild(successEl);
    }
    
    successEl.textContent = message;
    successEl.style.display = 'block';
    
    setTimeout(() => {
        successEl.style.display = 'none';
    }, duration);
}

/**
 * Safely execute a function with error handling
 * @param {Function} fn - Function to execute
 * @param {string} errorMsg - Error message if function fails
 * @returns {any} Function result or null if error
 */
function tryCatch(fn, errorMsg = 'An error occurred') {
    try {
        return fn();
    } catch (error) {
        console.error(errorMsg, error);
        showError(errorMsg);
        return null;
    }
}

// ==================== STORAGE UTILITIES ====================

/**
 * Safely get item from sessionStorage
 * @param {string} key - Storage key
 * @returns {any} Parsed value or null
 */
function getSessionData(key) {
    try {
        const data = sessionStorage.getItem(key);
        return data ? JSON.parse(data) : null;
    } catch (error) {
        console.error(`Error reading session data for ${key}:`, error);
        return null;
    }
}

/**
 * Safely set item in sessionStorage
 * @param {string} key - Storage key
 * @param {any} value - Value to store
 * @returns {boolean} True if successful
 */
function setSessionData(key, value) {
    try {
        sessionStorage.setItem(key, JSON.stringify(value));
        return true;
    } catch (error) {
        console.error(`Error saving session data for ${key}:`, error);
        showError('Failed to save data. Please check your browser storage.');
        return false;
    }
}

// ==================== NAVIGATION ====================

/**
 * Navigate to page with error handling
 * @param {string} url - URL to navigate to
 * @param {string} fallbackUrl - Fallback URL if navigation fails
 */
function navigateTo(url, fallbackUrl = 'index.html') {
    try {
        window.location.href = url;
    } catch (error) {
        console.error('Navigation error:', error);
        showError('Navigation failed. Redirecting...');
        setTimeout(() => {
            window.location.href = fallbackUrl;
        }, 2000);
    }
}

/**
 * Go back to previous page
 */
function goBack() {
    if (window.history.length > 1) {
        window.history.back();
    } else {
        navigateTo('index.html');
    }
}

// ==================== TRANSLATION UTILITIES ====================

/**
 * Update all translatable elements with current language
 * @param {Object} translations - Translation object {lang: {key: value}}
 */
function updateTranslations(translations) {
    const currentLang = getCurrentLanguage();
    const currentTranslations = translations[currentLang];
    
    if (!currentTranslations) {
        console.warn(`Translations not found for language: ${currentLang}`);
        return;
    }
    
    document.querySelectorAll('[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        if (currentTranslations[key]) {
            element.textContent = currentTranslations[key];
        }
    });
}

/**
 * Update language buttons active state
 * @param {string} lang - Active language code
 */
function updateLanguageButtons(lang) {
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
    });
}

// ==================== DEBOUNCE UTILITY ====================

/**
 * Debounce a function call
 * @param {Function} func - Function to debounce
 * @param {number} delay - Delay in milliseconds
 * @returns {Function} Debounced function
 */
function debounce(func, delay = 300) {
    let timeoutId;
    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => func.apply(this, args), delay);
    };
}

// ==================== VALIDATION UTILITIES ====================

/**
 * Validate email format
 * @param {string} email - Email address
 * @returns {boolean} True if valid
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Validate phone number (basic)
 * @param {string} phone - Phone number
 * @returns {boolean} True if valid
 */
function isValidPhone(phone) {
    const phoneRegex = /^[\d\s\-\+\(\)]{7,}$/;
    return phoneRegex.test(phone);
}

// ==================== DOM UTILITIES ====================

/**
 * Safely query selector
 * @param {string} selector - CSS selector
 * @returns {HTMLElement|null} Element or null
 */
function $(selector) {
    try {
        return document.querySelector(selector);
    } catch (error) {
        console.error(`Invalid selector: ${selector}`, error);
        return null;
    }
}

/**
 * Safely query all elements
 * @param {string} selector - CSS selector
 * @returns {Array<HTMLElement>} Array of elements
 */
function $$(selector) {
    try {
        return Array.from(document.querySelectorAll(selector));
    } catch (error) {
        console.error(`Invalid selector: ${selector}`, error);
        return [];
    }
}

export {
    getCurrentLanguage,
    setLanguage,
    toggleLanguageMenu,
    getCheckedCheckboxes,
    getCheckedCheckboxValues,
    isSelectPlaceholder,
    isFieldValid,
    showError,
    showSuccess,
    tryCatch,
    getSessionData,
    setSessionData,
    navigateTo,
    goBack,
    updateTranslations,
    updateLanguageButtons,
    debounce,
    isValidEmail,
    isValidPhone,
    SELECT_PLACEHOLDERS,
    $,
    $$
};


