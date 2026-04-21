# Redesigned HTML - Epson Utility Style
# This is just the CSS/HTML portion for redesign
# Clean white/light grey with Epson blue accent

EPSON_HTML = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Epson Print Utility</title>
  <style>
    :root {
      /* Epson Utility - Clean Professional */
      --bg: #f8f9fa;
      --bg-alt: #e9ecef;
      --panel: #ffffff;
      --panel-soft: #f1f3f5;
      --text: #212529;
      --text-muted: #6c757d;
      --line: #dee2e6;
      --accent: #0d6efd; /* Epson Blue */
      --accent-light: #e7f1ff;
      --ok: #198754;
      --ok-light: #d1e7dd;
      --warn: #ffc107;
      --warn-light: #fff3cd;
      --danger: #dc3545;
      --danger-light: #f8d7da;
      --shadow: 0 2px 8px rgba(0,0,0,0.08);
      --shadow-lg: 0 4px 16px rgba(0,0,0,0.12);
      --radius: 8px;
      --radius-sm: 4px;
      --radius-lg: 12px;
      --font: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    }

    /* Dark Theme */
    :root.dark {
      --bg: #1a1d20;
      --bg-alt: #2d3136;
      --panel: #252a30;
      --panel-soft: #32383e;
      --text: #e9ecef;
      --text-muted: #adb5bd;
      --line: #495057;
      --accent: #4dabf7;
      --accent-light: #1e3a5f;
      --ok: #75b798;
      --ok-light: #1e3a2a;
      --warn: #ffd43b;
      --warn-light: #3d320a;
      --danger: #ea868f;
      --danger-light: #47272a;
      --shadow: 0 2px 8px rgba(0,0,0,0.3);
      --shadow-lg: 0 4px 16px rgba(0,0,0,0.4);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }
    
    body {
      font-family: var(--font);
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
      min-height: 100vh;
      transition: background 0.2s, color 0.2s;
    }

    /* Header */
    header {
      background: var(--panel);
      border-bottom: 1px solid var(--line);
      padding: 16px 24px;
      position: sticky;
      top: 0;
      z-index: 100;
      box-shadow: var(--shadow);
    }

    header .brand {
      font-size: 20px;
      font-weight: 600;
      color: var(--accent);
    }

    header .brand span {
      font-weight: 400;
      color: var(--text-muted);
    }

    header .toolbar {
      display: flex;
      gap: 12px;
      margin-top: 12px;
      flex-wrap: wrap;
      align-items: center;
    }

    /* Controls */
    select, button, input {
      font-size: 14px;
      padding: 8px 12px;
      border: 1px solid var(--line);
      border-radius: var(--radius-sm);
      background: var(--panel);
      color: var(--text);
      outline: none;
      transition: border-color 0.15s, box-shadow 0.15s;
    }

    select:focus, button:focus, input:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 3px var(--accent-light);
    }

    button {
      cursor: pointer;
      font-weight: 500;
    }

    button:hover {
      background: var(--panel-soft);
    }

    button.primary {
      background: var(--accent);
      color: white;
      border-color: var(--accent);
    }

    button.primary:hover {
      background: #0b5ed7;
    }

    /* Cards */
    .container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 24px;
    }

    .card {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: var(--radius-lg);
      padding: 20px;
      margin-bottom: 16px;
      box-shadow: var(--shadow);
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 12px;
    }

    .card-title {
      font-size: 16px;
      font-weight: 600;
    }

    .card-subtitle {
      font-size: 13px;
      color: var(--text-muted);
      margin-top: 4px;
    }

    /* Badge / Status */
    .badge {
      display: inline-flex;
      align-items: center;
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 500;
    }

    .badge-ok { background: var(--ok-light); color: var(--ok); }
    .badge-warn { background: var(--warn-light); color: #856404; }
    .badge-danger { background: var(--danger-light); color: var(--danger); }
    .badge-info { background: var(--accent-light); color: var(--accent); }

    /* Grid */
    .grid {
      display: grid;
      gap: 16px;
    }

    .grid-2 { grid-template-columns: repeat(2, 1fr); }
    .grid-3 { grid-template-columns: repeat(3, 1fr); }
    .grid-4 { grid-template-columns: repeat(4, 1fr); }

    @media(max-width: 768px) {
      .grid-2, .grid-3, .grid-4 { grid-template-columns: 1fr; }
    }

    /* Stats */
    .stat-item {
      text-align: center;
      padding: 16px;
      background: var(--panel-soft);
      border-radius: var(--radius);
    }

    .stat-value {
      font-size: 28px;
      font-weight: 700;
      color: var(--accent);
    }

    .stat-label {
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 4px;
    }

    /* Printer Card */
    .printer-card {
      background: var(--panel-soft);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 16px;
    }

    .printer-name {
      font-weight: 600;
      font-size: 15px;
    }

    .printer-status {
      margin-top: 8px;
      font-size: 13px;
    }

    .printer-actions {
      margin-top: 12px;
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }

    .printer-actions button {
      font-size: 12px;
      padding: 6px 10px;
    }

    /* Action Grid */
    .action-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      gap: 8px;
      margin-top: 12px;
    }

    .action-grid button {
      font-size: 13px;
      padding: 10px;
    }

    /* Tables */
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
    }

    th, td {
      padding: 10px 12px;
      text-align: left;
      border-bottom: 1px solid var(--line);
    }

    th {
      font-weight: 600;
      background: var(--panel-soft);
      color: var(--text-muted);
      font-size: 12px;
      text-transform: uppercase;
    }

    tr:hover {
      background: var(--panel-soft);
    }

    /* Log */
    .log-entry {
      padding: 10px 12px;
      border-bottom: 1px solid var(--line);
      font-size: 13px;
    }

    .log-entry:last-child {
      border-bottom: none;
    }

    .log-time {
      color: var(--text-muted);
      font-size: 11px;
    }

    /* Progress Bar */
    .progress {
      height: 8px;
      background: var(--panel-soft);
      border-radius: 999px;
      overflow: hidden;
    }

    .progress-fill {
      height: 100%;
      background: var(--accent);
      transition: width 0.3s;
    }

    .progress-fill.ok { background: var(--ok); }
    .progress-fill.warn { background: var(--warn); }
    .progress-fill.danger { background: var(--danger); }

    /* Ink Level Display */
    .ink-levels {
      display: flex;
      gap: 12px;
      margin-top: 12px;
      flex-wrap: wrap;
    }

    .ink-cartridge {
      flex: 1;
      min-width: 80px;
    }

    .ink-label {
      font-size: 11px;
      color: var(--text-muted);
      margin-bottom: 4px;
    }

    .ink-bar {
      height: 6px;
      background: var(--panel-soft);
      border-radius: 3px;
      overflow: hidden;
    }

    .ink-fill {
      height: 100%;
      background: var(--accent);
    }

    .ink-fill.low { background: var(--danger); }
    .ink-fill.medium { background: var(--warn); }

    /* Utility List */
    .utility-list {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .utility-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 12px;
      background: var(--panel-soft);
      border-radius: var(--radius-sm);
    }

    .utility-name {
      font-weight: 500;
      font-size: 13px;
    }

    .utility-note {
      font-size: 11px;
      color: var(--text-muted);
    }

    /* Toast */
    #toastHost {
      position: fixed;
      bottom: 24px;
      right: 24px;
      z-index: 1000;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .toast {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 12px 16px;
      box-shadow: var(--shadow-lg);
      font-size: 13px;
      animation: slideIn 0.2s;
    }

    @keyframes slideIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* Empty State */
    .empty-state {
      padding: 32px;
      text-align: center;
      color: var(--text-muted);
      font-size: 14px;
    }

    /* Pre */
    pre {
      background: var(--panel-soft);
      border: 1px solid var(--line);
      border-radius: var(--radius-sm);
      padding: 12px;
      font-size: 12px;
      overflow-x: auto;
      max-height: 200px;
    }

    /* Footer */
    footer {
      padding: 24px;
      text-align: center;
      font-size: 12px;
      color: var(--text-muted);
      border-top: 1px solid var(--line);
      margin-top: 32px;
    }

    /* Responsive */
    @media(max-width: 640px) {
      .container { padding: 16px; }
      header { padding: 12px 16px; }
      .card { padding: 16px; }
    }
  </style>
</head>
<body>
  <header>
    <div class="brand">Epson Print <span>Utility</span></div>
    <div class="toolbar">
      <select id="modelSelect">
        <option value="L3110">L3110</option>
        <option value="L3150">L3150</option>
        <option value="L3210">L3210</option>
        <option value="L3250">L3250</option>
        <option value="L5190">L5190</option>
      </select>
      <button onclick="refreshAll()">Refresh</button>
      <button onclick="toggleTheme()">Theme</button>
    </div>
  </header>

  <div class="container">
    <!-- Dashboard Overview -->
    <div class="card">
      <div class="card-header">
        <div>
          <div class="card-title">Dashboard</div>
          <div class="card-subtitle">Print job summary and printer status</div>
        </div>
      </div>
      <div class="grid grid-4" id="statsGrid">
        <div class="empty-state">Loading...</div>
      </div>
    </div>

    <!-- Printers -->
    <div class="card">
      <div class="card-header">
        <div>
          <div class="card-title">Connected Printers</div>
          <div class="card-subtitle">Monitor and maintain your printers</div>
        </div>
      </div>
      <div class="grid grid-3" id="printerGrid">
        <div class="empty-state">Loading printers...</div>
      </div>
    </div>

    <!-- Print Jobs -->
    <div class="card">
      <div class="card-header">
        <div>
          <div class="card-title">Recent Jobs</div>
          <div class="card-subtitle">Latest print jobs from CUPS and portal</div>
        </div>
      </div>
      <div id="jobsFeed">
        <div class="empty-state">Loading jobs...</div>
      </div>
    </div>

    <!-- Activity Log -->
    <div class="card">
      <div class="card-header">
        <div>
          <div class="card-title">Activity Log</div>
          <div class="card-subtitle">Maintenance actions and system events</div>
        </div>
      </div>
      <div id="activityFeed">
        <div class="empty-state">Loading activity...</div>
      </div>
    </div>

    <!-- System -->
    <div class="card">
      <div class="card-header">
        <div>
          <div class="card-title">System Status</div>
        </div>
      </div>
      <div class="grid grid-2">
        <div>
          <div class="card-title" style="font-size:14px;">USB Devices</div>
          <pre id="usbList">Loading...</pre>
        </div>
        <div>
          <div class="card-title" style="font-size:14px;">ipp-usb</div>
          <pre id="ippUsbStatus">Loading...</pre>
        </div>
      </div>
    </div>
  </div>

  <footer>
    <span>Epson Print Utility</span> | Armbian PrintServer
  </footer>

  <div id="toastHost" aria-live="polite"></div>

  <script>
    // Placeholder for JS - reusing existing functions from original
    function toggleTheme() {
      document.documentElement.classList.toggle('dark');
      localStorage.setItem('theme', document.documentElement.classList.contains('dark') ? 'dark' : 'light');
    }

    // Theme init
    (function() {
      if (localStorage.getItem('theme') === 'dark') {
        document.documentElement.classList.add('dark');
      }
    })();

    // Toast notifications
    function notify(msg) {
      var host = document.getElementById('toastHost');
      if (!host) { alert(msg); return; }
      var el = document.createElement('div');
      el.className = 'toast';
      el.textContent = msg;
      host.appendChild(el);
      setTimeout(function() { try { el.remove(); } catch(e) {} }, 4000);
    }

    // API helper
    async function api(path) {
      var res = await fetch(path);
      var text = await res.text();
      var data = {};
      if (text) {
        try { data = JSON.parse(text); } catch(e) {}
      }
      if (!res.ok) throw new Error(data.error || 'Error ' + res.status);
      return data;
    }

    // Badge helper
    function badge(text, cls) {
      return '<span class="badge badge-' + cls + '">' + text + '</span>';
    }

    // Safe text
    function safe(v) {
      if (v === null || v === undefined) return '-';
      return String(v).replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // Data placeholders
    var STATUS_TIMER = null;
    var PRINTERS = [];
    var DASHBOARD_DATA = null;

    // These will be populated by the backend functions
    async function refreshAll() {
      try {
        notify('Refreshing...');
        var printers = await api('/printers');
        PRINTERS = printers.printers || [];
        
        var summary = await api('/dashboard/summary?limit=100');
        DASHBOARD_DATA = summary;
        
        renderDashboard(summary);
        renderPrinters(PRINTERS, summary);
        renderJobs(summary);
        renderActivity();
        
        notify('Updated');
      } catch(e) {
        notify('Error: ' + e.message);
      }
    }

    function renderDashboard(data) {
      if (!data || !data.overview) return;
      var o = data.overview;
      var html = '';
      
      var totalJobs = o.total_jobs || 0;
      var totalPages = o.total_pages || 0;
      var activePrinter = o.most_active || '-';
      
      html += '<div class="stat-item"><div class="stat-value">' + totalJobs + '</div><div class="stat-label">Total Jobs</div></div>';
      html += '<div class="stat-item"><div class="stat-value">' + totalPages + '</div><div class="stat-label">Pages Printed</div></div>';
      html += '<div class="stat-item"><div class="stat-value">' + safe(activePrinter) + '</div><div class="stat-label">Most Active</div></div>';
      html += '<div class="stat-item"><div class="stat-value">' + PRINTERS.length + '</div><div class="stat-label">Printers</div></div>';
      
      document.getElementById('statsGrid').innerHTML = html;
    }

    function renderPrinters(printers, summary) {
      if (!printers || !printers.length) {
        document.getElementById('printerGrid').innerHTML = '<div class="empty-state">No printers detected</div>';
        return;
      }
      
      var html = '';
      printers.forEach(function(p) {
        var status = 'Unknown';
        var statusCls = 'info';
        
        // Try to get status from summary
        if (summary && summary.usage) {
          var printerUsage = summary.usage[p.name];
          if (printerUsage && printerUsage.status) {
            status = printerUsage.status;
            if (status === 'ready' || status === 'ok') statusCls = 'ok';
            else if (status === 'error' || status === 'offline') statusCls = 'danger';
          }
        }
        
        html += '<div class="printer-card">';
        html += '<div class="printer-name">' + safe(p.name) + '</div>';
        html += '<div class="printer-status">' + badge(status.toUpperCase(), statusCls) + '</div>';
        html += '<div style="margin-top:8px;font-size:12px;color:var(--text-muted);">';
        if (p.uri) html += 'URI: ' + safe(p.uri);
        html += '</div>';
        html += '<div class="printer-actions">';
        html += '<button onclick="refreshPrinter(\'' + p.name + '\')">Status</button>';
        html += '<button onclick="cleanPrinter(\'' + p.name + '\')">Clean</button>';
        html += '<button onclick="checkNozzle(\'' + p.name + '\')">Nozzle</button>';
        html += '</div>';
        html += '</div>';
      });
      
      document.getElementById('printerGrid').innerHTML = html;
    }

    function renderJobs(data) {
      if (!data || !data.jobs || !data.jobs.length) {
        document.getElementById('jobsFeed').innerHTML = '<div class="empty-state">No recent jobs</div>';
        return;
      }
      
      var jobs = data.jobs.slice(0, 20);
      var html = '<table><thead><tr><th>Time</th><th>Printer</th><th>Pages</th><th>Source</th></tr></thead><tbody>';
      
      jobs.forEach(function(j) {
        var time = j.time || '-';
        var printer = j.printer || '-';
        var pages = j.pages_logged || j.max_page || 0;
        var source = j.source || j.portal_source || '-';
        
        html += '<tr>';
        html += '<td>' + safe(time) + '</td>';
        html += '<td>' + safe(printer) + '</td>';
        html += '<td>' + pages + '</td>';
        html += '<td>' + badge(safe(source).toUpperCase(), 'info') + '</td>';
        html += '</tr>';
      });
      
      html += '</tbody></table>';
      document.getElementById('jobsFeed').innerHTML = html;
    }

    function renderActivity() {
      // Activity is loaded from /logs
      api('/logs').then(function(data) {
        if (!data || !data.logs || !data.logs.length) {
          document.getElementById('activityFeed').innerHTML = '<div class="empty-state">No activity</div>';
          return;
        }
        
        var logs = data.logs.slice(0, 15);
        var html = '';
        
        logs.forEach(function(l) {
          html += '<div class="log-entry">';
          html += '<span class="log-time">' + safe(l.time || l.timestamp) + '</span>';
          html += ' <strong>' + safe(l.message || l.action) + '</strong>';
          if (l.details) html += ': ' + safe(l.details);
          html += '</div>';
        });
        
        document.getElementById('activityFeed').innerHTML = html;
      }).catch(function() {
        document.getElementById('activityFeed').innerHTML = '<div class="empty-state">Failed to load</div>';
      });
    }

    function refreshPrinter(name) {
      notify('Getting status for ' + name + '...');
      api('/status?printer=' + encodeURIComponent(name)).then(function(data) {
        notify(name + ': ' + (data.ok ? 'OK' : data.error));
      }).catch(function(e) {
        notify('Error: ' + e.message);
      });
    }

    function cleanPrinter(name) {
      notify('Running clean on ' + name + '...');
      api('/clean?printer=' + encodeURIComponent(name)).then(function(data) {
        notify(name + ' clean: ' + (data.ok ? 'Done' : data.error));
      }).catch(function(e) {
        notify('Error: ' + e.message);
      });
    }

    function checkNozzle(name) {
      notify('Checking nozzle for ' + name + '...');
      api('/v7/nozzle?printer=' + encodeURIComponent(name)).then(function(data) {
        notify(name + ' nozzle: ' + (data.ok ? 'OK' : data.error));
      }).catch(function(e) {
        notify('Error: ' + e.message);
      });
    }

    // Load USB
    api('/usb').then(function(data) {
      document.getElementById('usbList').textContent = JSON.stringify(data, null, 2);
    }).catch(function(e) {
      document.getElementById('usbList').textContent = 'Error: ' + e.message;
    });

    // Load ipp-usb
    api('/ippusb').then(function(data) {
      document.getElementById('ippUsbStatus').textContent = JSON.stringify(data, null, 2);
    }).catch(function(e) {
      document.getElementById('ippUsbStatus').textContent = 'Error: ' + e.message;
    });

    // Auto refresh
    setTimeout(refreshAll, 100);
    STATUS_TIMER = setInterval(refreshAll, 30000);
  </script>
</body>
</html>
"""