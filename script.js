const runbookStructure = {
    'alertmanager': {
        name: 'Alertmanager',
        alerts: {
            'high_memory_usage': 'High Memory Usage',
            'notification_failures': 'Notification Failures'
        }
    },
    'prometheus': {
        name: 'Prometheus',
        alerts: {
            'high_query_load': 'High Query Load',
            'storage_filling_up': 'Storage Filling Up'
        }
    }
};

function createNavigation() {
    const nav = document.getElementById('alertNav');
    
    Object.entries(runbookStructure).forEach(([appKey, appData]) => {
        const section = document.createElement('div');
        section.className = 'app-section';
        
        const header = document.createElement('h2');
        header.innerHTML = `${appData.name} <span class="arrow">›</span>`;
        header.addEventListener('click', () => {
            section.classList.toggle('active');
        });
        
        const alertsList = document.createElement('div');
        alertsList.className = 'alerts';
        
        Object.entries(appData.alerts).forEach(([alertKey, alertName]) => {
            const alert = document.createElement('a');
            alert.className = 'alert-item';
            alert.textContent = alertName;
            alert.href = `#${appKey}/${alertKey}`;
            alert.addEventListener('click', (e) => {
                e.preventDefault();
                loadRunbook(appKey, alertKey);
                document.querySelectorAll('.alert-item').forEach(item => item.classList.remove('active'));
                alert.classList.add('active');
            });
            alertsList.appendChild(alert);
        });
        
        section.appendChild(header);
        section.appendChild(alertsList);
        nav.appendChild(section);
    });
}

async function loadRunbook(app, alert) {
    try {
        const response = await fetch(`runbooks/${app}/${alert}.md`);
        if (!response.ok) throw new Error('Failed to load runbook');
        
        const markdown = await response.text();
        const content = marked.parse(markdown);
        document.getElementById('runbookContent').innerHTML = content;
    } catch (error) {
        console.error('Error loading runbook:', error);
        document.getElementById('runbookContent').innerHTML = '<div class="welcome"><h1>Error</h1><p>Failed to load runbook content.</p></div>';
    }
}

function setupSearch() {
    const searchInput = document.getElementById('searchInput');
    searchInput.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        
        document.querySelectorAll('.alert-item').forEach(item => {
            const alertName = item.textContent.toLowerCase();
            const appName = item.closest('.app-section').querySelector('h2').textContent.toLowerCase();
            
            if (alertName.includes(searchTerm) || appName.includes(searchTerm)) {
                item.style.display = 'block';
                item.closest('.app-section').classList.add('active');
            } else {
                item.style.display = 'none';
            }
            
            // Show/hide app sections based on visible alerts
            document.querySelectorAll('.app-section').forEach(section => {
                const hasVisibleAlerts = Array.from(section.querySelectorAll('.alert-item'))
                    .some(alert => alert.style.display !== 'none');
                section.style.display = hasVisibleAlerts ? 'block' : 'none';
            });
        });
    });
}

// Handle initial hash route
function handleInitialRoute() {
    const hash = window.location.hash.slice(1);
    if (hash) {
        const [app, alert] = hash.split('/');
        if (app && alert) {
            loadRunbook(app, alert);
            // Activate correct section and alert
            const section = document.querySelector(`.app-section:has(a[href="#${app}/${alert}"])`);
            if (section) {
                section.classList.add('active');
                const alertItem = section.querySelector(`a[href="#${app}/${alert}"]`);
                if (alertItem) alertItem.classList.add('active');
            }
        }
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    createNavigation();
    setupSearch();
    handleInitialRoute();
});