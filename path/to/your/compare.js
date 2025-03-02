// Add search functionality to store selection dropdown
function setupStoreSearch() {
  // Get your store dropdown/list element
  const storeSelector = document.getElementById('storeSelector'); // Update with your actual selector ID
  const searchInput = document.getElementById('storeSearchInput'); // Update or create this input
  
  // If the search input doesn't exist, create one
  if (!searchInput && storeSelector) {
    const searchContainer = document.createElement('div');
    searchContainer.className = 'search-container';
    
    const newSearchInput = document.createElement('input');
    newSearchInput.id = 'storeSearchInput';
    newSearchInput.type = 'text';
    newSearchInput.placeholder = 'Search stores...';
    newSearchInput.className = 'store-search-input';
    
    // Insert the search input before the store selector
    storeSelector.parentNode.insertBefore(searchContainer, storeSelector);
    searchContainer.appendChild(newSearchInput);
    
    // Add event listener for filtering
    newSearchInput.addEventListener('input', filterStores);
  }
}

// Filter stores based on search input
function filterStores() {
  const searchInput = document.getElementById('storeSearchInput');
  const storeSelector = document.getElementById('storeSelector');
  
  if (!searchInput || !storeSelector) return;
  
  const searchTerm = searchInput.value.toLowerCase();
  const storeOptions = storeSelector.options || storeSelector.querySelectorAll('option');
  
  // Loop through all options and show/hide based on search term
  Array.from(storeOptions).forEach(option => {
    const optionText = option.textContent.toLowerCase();
    if (optionText.includes(searchTerm)) {
      option.style.display = ''; // Show matching options
    } else {
      option.style.display = 'none'; // Hide non-matching options
    }
  });
}

// Call this function when the compare tab is loaded or activated
function initCompareTab() {
  setupStoreSearch();
  // Your other compare tab initialization code
}

// Make sure to call initCompareTab when appropriate 