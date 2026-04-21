/**
 * renderer.js - Qwen Unleashed UI
 * Fixed file upload reading, token position
 */

let internetEnabled = false;
let debateEnabled = false;
let chatHistory = [];
let selectedFiles = [];
let selectedBrain = 'qwen-3.6-plus';
let currentProject = null;
let projects = [];

const chatArea = document.getElementById('chat-area');
const messageInput = document.getElementById('message-input');
const sendBtn = document.getElementById('send-btn');
const fileInput = document.getElementById('file-upload');
const filePreview = document.getElementById('file-preview');
const brainSelect = document.getElementById('brain-select');
const projectsList = document.getElementById('projects-list');

function autoResizeTextarea() {
    messageInput.style.height = 'auto';
    messageInput.style.height = Math.min(messageInput.scrollHeight, 200) + 'px';
}

async function checkApiStatus() {
    try {
        const status = await window.electronAPI.getStatus();
        
        document.getElementById('status-dialagram').classList.toggle('active', status.dialagram);
        document.getElementById('status-dialagram').classList.toggle('offline', !status.dialagram);
        document.getElementById('status-opencode').classList.toggle('active', status.opencode);
        document.getElementById('status-opencode').classList.toggle('opencode', status.opencode);
        document.getElementById('status-ollama').classList.toggle('active', status.localModels?.length > 0);

        return status;
    } catch (e) {
        console.error('Status check failed:', e);
        return null;
    }
}

async function loadModels() {
    try {
        const models = await window.electronAPI.getModels();
        const previousSelection = selectedBrain;

        brainSelect.innerHTML = '';

        if (models.dialagram?.length > 0) {
            const optgroup = document.createElement('optgroup');
            optgroup.label = '📡 Dialagram Cloud';
            models.dialagram.forEach(m => {
                const opt = document.createElement('option');
                opt.value = m.id;
                opt.textContent = m.name;
                optgroup.appendChild(opt);
            });
            brainSelect.appendChild(optgroup);
        }

        if (models.localModels?.length > 0) {
            const optgroup = document.createElement('optgroup');
            optgroup.label = '💻 Local (Ollama)';
            models.localModels.forEach(m => {
                const modelId = m.id || m.name || m.model;
                if (!modelId) return;

                const opt = document.createElement('option');
                opt.value = modelId;
                opt.textContent = `${modelId} (Local)`;
                optgroup.appendChild(opt);
            });
            if (optgroup.children.length > 0) {
                brainSelect.appendChild(optgroup);
            }
        }

        if (models.opencodeAvailable) {
            const optgroup = document.createElement('optgroup');
            optgroup.label = '🔧 OpenCode';
            const opt = document.createElement('option');
            opt.value = 'opencode';
            opt.textContent = 'OpenCode (Local)';
            optgroup.appendChild(opt);
            brainSelect.appendChild(optgroup);
        }

        const hasPreviousSelection = Array.from(brainSelect.options).some(opt => opt.value === previousSelection);
        if (hasPreviousSelection) {
            brainSelect.value = previousSelection;
        } else if (brainSelect.options.length > 0) {
            brainSelect.selectedIndex = 0;
            selectedBrain = brainSelect.value;
        }

        updateModelBadge();
    } catch (e) {
        console.error('Failed to load models:', e);
    }
}

async function loadProjects() {
    try {
        projects = await window.electronAPI.getProjects();
        renderProjects();
    } catch (e) {
        console.error('Failed to load projects:', e);
    }
}

function renderProjects() {
    projectsList.innerHTML = `
        <div class="project-item ${currentProject === null ? 'active' : ''}" onclick="selectProject(null)">
            <span class="icon">💬</span>
            <span class="name">Global Chat</span>
        </div>
    `;

    projects.forEach(p => {
        projectsList.innerHTML += `
            <div class="project-item ${currentProject?.id === p.id ? 'active' : ''}" onclick="selectProject(${JSON.stringify(p).replace(/"/g, '&quot;')})">
                <span class="icon">📁</span>
                <span class="name">${escapeHtml(p.name)}</span>
                <button class="delete-btn" onclick="event.stopPropagation(); deleteProject('${p.id}')">✕</button>
            </div>
        `;
    });
}

function selectProject(project) {
    currentProject = project;
    renderProjects();
    loadChatHistory();
}

async function loadChatHistory() {
    try {
        chatHistory = await window.electronAPI.getChat(currentProject?.id || 'global');
        renderChat();
    } catch (e) {
        console.error('Failed to load chat:', e);
    }
}

async function loadTokenStats() {
    try {
        const stats = await window.electronAPI.getTokenStats();
        if (stats) {
            document.getElementById('token-stats').textContent = `${(stats.totalTokens / 1000).toFixed(1)}K tokens | ${stats.cost}`;
        }
    } catch {
        document.getElementById('token-stats').textContent = '--';
    }
}

function updateModelBadge() {
    const selected = brainSelect.options[brainSelect.selectedIndex];
    if (selected) {
        const text = selected.textContent;
        document.getElementById('current-model-badge').textContent = text.split('(')[0].trim().substring(0, 12);
    }
}

brainSelect.addEventListener('change', () => {
    selectedBrain = brainSelect.value;
    updateModelBadge();
});

messageInput.addEventListener('input', autoResizeTextarea);

messageInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});

sendBtn.addEventListener('click', sendMessage);
fileInput.addEventListener('change', handleFileSelect);

function handleFileSelect(e) {
    const files = Array.from(e.target.files);
    const textFiles = files.filter(f => !f.type.startsWith('image/'));
    const imageFiles = files.filter(f => f.type.startsWith('image/'));
    
    if (imageFiles.length > 0) {
        showWarning('⚠️ Image files not supported.');
    }
    
    // Read file contents
    textFiles.forEach(file => {
        const reader = new FileReader();
        reader.onload = (event) => {
            selectedFiles.push({
                name: file.name,
                content: event.target.result,
                type: file.type
            });
            renderFilePreview();
        };
        reader.readAsText(file);
    });
    
    e.target.value = '';
}

function renderFilePreview() {
    if (selectedFiles.length === 0) {
        filePreview.classList.add('hidden');
        filePreview.innerHTML = '';
        return;
    }
    
    filePreview.classList.remove('hidden');
    filePreview.innerHTML = selectedFiles.map((f, i) => `
        <div class="file-card">
            <span>📄</span>
            <span title="${escapeHtml(f.name)}">${escapeHtml(f.name)}</span>
            <button class="remove" onclick="removeFile(${i})">✕</button>
        </div>
    `).join('');
}

window.removeFile = (index) => {
    selectedFiles.splice(index, 1);
    renderFilePreview();
};

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showWarning(text) {
    chatArea.innerHTML += `
        <div class="message">
            <div class="avatar ai-avatar">!</div>
            <div class="warning-msg">${escapeHtml(text)}</div>
        </div>
    `;
    scrollToBottom();
}

function showInfo(text) {
    chatArea.innerHTML += `
        <div class="message">
            <div class="avatar ai-avatar">i</div>
            <div class="info-msg">${escapeHtml(text)}</div>
        </div>
    `;
    scrollToBottom();
}

function scrollToBottom() {
    setTimeout(() => {
        chatArea.scrollTop = chatArea.scrollHeight;
    }, 50);
}

async function sendMessage(overrideText = null) {
    const text = overrideText || messageInput.value.trim();
    if (!text) return;

    document.getElementById('welcome-card')?.remove();

    messageInput.value = '';
    messageInput.style.height = 'auto';

    // Build file context with actual content
    let filesContext = '';
    if (selectedFiles.length > 0) {
        filesContext = '\n\n[Attached Files]\n';
        selectedFiles.forEach(f => {
            filesContext += `\n--- ${f.name} ---\n${f.content}\n`;
        });
    }

    chatArea.innerHTML += `
        <div class="message user">
            <div class="avatar user-avatar">ME</div>
            <div class="bubble user-bubble">${escapeHtml(text)}</div>
        </div>
    `;
    scrollToBottom();

    const msgId = 'ai-' + Date.now();
    const typingText = debateEnabled ? 'Dewan AI sedang berdiskusi...' : 'Thinking...';
    chatArea.innerHTML += `
        <div class="message" id="${msgId}">
            <div class="avatar ai-avatar">Q</div>
            <div class="typing-indicator">
                <div class="typing-dots"><span></span><span></span><span></span></div>
                <span class="typing-text">${typingText}</span>
            </div>
        </div>
    `;
    scrollToBottom();

    try {
        const response = await window.electronAPI.chat({
            message: text + filesContext,
            useInternet: internetEnabled,
            projectId: currentProject?.id || 'global',
            history: chatHistory,
            debateMode: debateEnabled,
            selectedBrain: selectedBrain
        });

        document.getElementById(msgId)?.remove();
        selectedFiles = [];
        renderFilePreview();
        
        chatHistory.push({ role: 'user', text: text + filesContext });
        chatHistory.push({ role: 'assistant', text: response });
        
        renderChat();
        loadTokenStats();

        if (response.status === 'disconnected') {
            showInfo('⚠️ Dialagram API unreachable.');
        }

    } catch (e) {
        const msgEl = document.getElementById(msgId);
        if (msgEl) {
            msgEl.innerHTML = `
                <div class="avatar ai-avatar">!</div>
                <div class="error-msg">Error: ${escapeHtml(e.message)}</div>
            `;
        }
    }
}

function renderChat() {
    if (chatHistory.length === 0) return;

    let html = '';
    
    chatHistory.forEach(m => {
        if (m.role === 'user') {
            html += `
                <div class="message user">
                    <div class="avatar user-avatar">ME</div>
                    <div class="bubble user-bubble">${escapeHtml(m.text)}</div>
                </div>
            `;
        } else {
            const data = typeof m.text === 'object' ? m.text : { primary: m.text, synthesis: m.text };
            
            if (data.debateMode) {
                html += `
                    <div class="message">
                        <div class="avatar ai-avatar">Q</div>
                        <div class="ai-response">
                            <div style="font-size: 10px; color: #f472b6; margin-bottom: 10px;">🧠 Dewan AI (Debate Mode)</div>
                            <div class="brain-grid">
                                <div class="brain-card primary">
                                    <div class="brain-label">${data.models?.primary || 'Agent 1'}</div>
                                    <div class="brain-content">${escapeHtml(data.primary || 'N/A')}</div>
                                </div>
                                <div class="brain-card secondary">
                                    <div class="brain-label">${data.models?.Dewan || 'Agent 2'}</div>
                                    <div class="brain-content">${escapeHtml(data.Dewan || 'N/A')}</div>
                                </div>
                            </div>
                            <div class="synthesis-section">
                                <div class="synthesis-header">
                                    <h4>Final Synthesis (Primary)</h4>
                                    <button class="copy-btn" onclick="copySynthesis(this, \`${escapeForJs(data.synthesis || data.primary || '')}\`)">Copy</button>
                                </div>
                                <div class="brain-content">${escapeHtml(data.synthesis || data.primary || 'N/A')}</div>
                            </div>
                        </div>
                    </div>
                `;
            } else {
                html += `
                    <div class="message">
                        <div class="avatar ai-avatar">Q</div>
                        <div class="ai-response">
                            <div class="brain-card primary" style="max-width: 85%;">
                                <div class="brain-label">${data.model || selectedBrain}</div>
                                <div class="brain-content">${escapeHtml(data.primary || data.synthesis || 'N/A')}</div>
                            </div>
                        </div>
                    </div>
                `;
            }
        }
    });

    chatArea.innerHTML = html;
    scrollToBottom();
}

function escapeForJs(text) {
    return text.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$/g, '\\$');
}

window.copySynthesis = async (btn, text) => {
    try {
        await window.electronAPI.copyToClipboard(text);
        btn.textContent = 'Copied!';
        btn.classList.add('copied');
        setTimeout(() => {
            btn.textContent = 'Copy';
            btn.classList.remove('copied');
        }, 2000);
    } catch (e) {
        console.error('Copy failed:', e);
    }
};

function toggleDebate() {
    debateEnabled = !debateEnabled;
    document.getElementById('btn-debate').classList.toggle('active', debateEnabled);
}

function toggleInternet() {
    internetEnabled = !internetEnabled;
    document.getElementById('btn-internet').classList.toggle('active', internetEnabled);
}

function openNewProjectModal() {
    document.getElementById('new-project-modal').classList.remove('hidden');
    document.getElementById('project-name-input').focus();
}

function closeNewProjectModal() {
    document.getElementById('new-project-modal').classList.add('hidden');
    document.getElementById('project-name-input').value = '';
}

async function confirmNewProject() {
    const name = document.getElementById('project-name-input').value.trim();
    if (!name) return;

    const folderPath = await window.electronAPI.selectFolder();
    if (!folderPath) return;

    try {
        await window.electronAPI.addProject({ name, path: folderPath });
        await loadProjects();
        closeNewProjectModal();
        showInfo(`Project "${name}" created!`);
    } catch (e) {
        console.error('Failed to create project:', e);
    }
}

async function deleteProject(projectId) {
    if (!confirm('Delete this project?')) return;
    
    try {
        await window.electronAPI.deleteProject(projectId);
        if (currentProject?.id === projectId) {
            currentProject = null;
        }
        await loadProjects();
        showInfo('Project deleted');
    } catch (e) {
        console.error('Failed to delete project:', e);
    }
}

async function openSettingsModal() {
    document.getElementById('settings-modal').classList.remove('hidden');
    try {
        const config = await window.electronAPI.getApiConfig();
        document.getElementById('api-key-dialagram').value = '';
        document.getElementById('api-key-openai').value = config.openai.hasKey ? '********' : '';
        document.getElementById('api-key-openrouter').value = config.openrouter.hasKey ? '********' : '';
    } catch (e) {
        console.error('Failed to load API config:', e);
    }
}

function closeSettingsModal() {
    document.getElementById('settings-modal').classList.add('hidden');
}

async function saveApiSettings() {
    const dialagramKey = document.getElementById('api-key-dialagram').value.trim();
    const openaiKey = document.getElementById('api-key-openai').value.trim();
    const openrouterKey = document.getElementById('api-key-openrouter').value.trim();

    try {
        if (dialagramKey && dialagramKey !== '********') {
            await window.electronAPI.setApiConfig('dialagram', dialagramKey);
        }
        if (openaiKey && openaiKey !== '********') {
            await window.electronAPI.setApiConfig('openai', openaiKey);
        }
        if (openrouterKey && openrouterKey !== '********') {
            await window.electronAPI.setApiConfig('openrouter', openrouterKey);
        }
        closeSettingsModal();
        showInfo('API settings saved!');
        loadModels();
        checkApiStatus();
    } catch (e) {
        console.error('Failed to save API settings:', e);
        showWarning('Failed to save API settings');
    }
}

window.toggleDebate = toggleDebate;
window.toggleInternet = toggleInternet;
window.openNewProjectModal = openNewProjectModal;
window.closeNewProjectModal = closeNewProjectModal;
window.confirmNewProject = confirmNewProject;
window.selectProject = selectProject;
window.deleteProject = deleteProject;
window.openSettingsModal = openSettingsModal;
window.closeSettingsModal = closeSettingsModal;
window.saveApiSettings = saveApiSettings;

checkApiStatus();
loadModels();
loadProjects();
loadTokenStats();

setInterval(checkApiStatus, 30000);
setInterval(loadTokenStats, 30000);
