// Sidebar toggle functionality with local storage persistence
document.addEventListener('DOMContentLoaded', function() {
  console.log('Sidebar toggle script loaded');
  
  // Initialize sidebar sections
  const sections = ['PLAYERS', 'THE WORLD', 'THE GAME'];
  
  sections.forEach(section => {
    // Get the header element using a more specific selector
    const headers = document.querySelectorAll('.sidebar-menu li.header');
    const header = Array.from(headers).find(h => h.textContent.trim() === section);
    
    if (!header) {
      console.log(`Header not found for section: ${section}`);
      return;
    }
    
    console.log(`Found header for section: ${section}`);
    
    // Get all items under this section
    const items = [];
    let nextElement = header.nextElementSibling;
    while (nextElement && !nextElement.classList.contains('header')) {
      items.push(nextElement);
      nextElement = nextElement.nextElementSibling;
    }
    
    console.log(`Found ${items.length} items for section: ${section}`);
    
    // Create toggle button
    const toggleBtn = document.createElement('span');
    toggleBtn.className = 'pull-right-container';
    toggleBtn.innerHTML = '<i class="fa fa-angle-down"></i>';
    header.appendChild(toggleBtn);
    
    // Get initial state from localStorage
    const isCollapsed = localStorage.getItem(`sidebar_${section}`) === 'true';
    
    // Set initial state
    if (isCollapsed) {
      items.forEach(item => {
        item.style.display = 'none';
        console.log(`Hiding item: ${item.textContent.trim()}`);
      });
      toggleBtn.querySelector('i').className = 'fa fa-angle-right';
    }
    
    // Add click handler
    header.addEventListener('click', function(e) {
      // Don't toggle if clicking on a link
      if (e.target.tagName === 'A') return;
      
      const isCurrentlyCollapsed = items[0].style.display === 'none';
      console.log(`Toggling section ${section}, currently collapsed: ${isCurrentlyCollapsed}`);
      
      // Toggle visibility
      items.forEach(item => {
        item.style.display = isCurrentlyCollapsed ? 'block' : 'none';
        console.log(`Setting display to ${isCurrentlyCollapsed ? 'block' : 'none'} for: ${item.textContent.trim()}`);
      });
      
      // Update icon
      toggleBtn.querySelector('i').className = isCurrentlyCollapsed ? 'fa fa-angle-down' : 'fa fa-angle-right';
      
      // Save state to localStorage
      localStorage.setItem(`sidebar_${section}`, !isCurrentlyCollapsed);
    });
  });
}); 