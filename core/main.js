const { app, BrowserWindow, ipcMain, dialog, clipboard, Menu } = require('electron');
const path = require('path');
const fs = require('fs').promises;
require('dotenv').config({ path: path.join(__dirname, '.env') });

let mainWindow;

const userDataPath = app.getPath('userData');
const PROJECTS_FILE = path.join(userDataPath, 'projects.json');
const CHATS_FILE = path.join(userDataPath, 'chats.json');
const CONFIG_FILE = path.join(userDataPath, 'api-config.json');
const SETTINGS_FILE = path.join(userDataPath, 'settings.json');
const TOKEN_USAGE_FILE = path.join(userDataPath, 'token-usage.json');
const UPLOADS_DIR = path.join(userDataPath, 'temp-uploads');
const MAX_STAGED_FILE_BYTES = 25 * 1024 * 1024;
const MAX_FILE_CONTEXT_CHARS = 180000;

async function loadConfig() {
    try {
        const data = await fs.readFile(CONFIG_FILE, 'utf8');
        const saved = JSON.parse(data);
        if (saved.dialagram) API_CONFIG.dialagram.key = saved.dialagram.key || API_CONFIG.dialagram.key;
        if (saved.openai) API_CONFIG.openai = { ...API_CONFIG.openai, ...saved.openai };
        if (saved.openrouter) API_CONFIG.openrouter = { ...API_CONFIG.openrouter, ...saved.openrouter };
    } catch {}
}

async function saveConfig() {
    await fs.writeFile(CONFIG_FILE, JSON.stringify({
        dialagram: { key: API_CONFIG.dialagram.key },
        openai: { key: API_CONFIG.openai.key },
        openrouter: { key: API_CONFIG.openrouter.key }
    }, null, 2));
}

async function loadSettings() {
    try { return JSON.parse(await fs.readFile(SETTINGS_FILE, 'utf8')); }
    catch { return {}; }
}

async function saveSettings(settings) {
    await fs.writeFile(SETTINGS_FILE, JSON.stringify(settings, null, 2));
}

const DIALAGRAM_URL = 'https://www.dialagram.me/router/v1';
const OPENAI_URL = 'https://api.openai.com/v1';
const OPENROUTER_URL = 'https://openrouter.ai/api/v1';
const OLLAMA_URL = process.env.OLLAMA_URL || 'http://localhost:11434';

let API_CONFIG = {
    dialagram: {
        url: 'https://www.dialagram.me/router/v1',
        key: process.env.NEXUM_API_KEY || '',
        models: ['qwen-3.6-plus', 'qwen-3.5-plus', 'qwen-3.6-plus-thinking', 'qwen-3.5-plus-thinking']
    },
    openai: { url: 'https://api.openai.com/v1', key: '', models: ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo'] },
    openrouter: { url: 'https://openrouter.ai/api/v1', key: '', models: [] },
    ollama: { url: OLLAMA_URL, key: '', models: [] }
};

const OPENCODE_URL = 'http://127.0.0.1:8080';

const MODELS = {
    primary: { id: 'qwen-3.6-plus', name: 'Qwen 3.6 Plus', provider: 'dialagram' },
    speed: { id: 'qwen-3.5-plus', name: 'Qwen 3.5 Plus', provider: 'dialagram' },
    thinking: { id: 'qwen-3.6-plus-thinking', name: 'Qwen 3.6 Thinking', provider: 'dialagram' },
};

const DEWAN_MODELS = {
    agent1: { id: 'qwen-3.6-plus', name: 'Qwen 3.6 (Agent 1)', provider: 'dialagram' },
    agent2: { id: 'qwen-3.5-plus-thinking', name: 'Qwen 3.5 Thinking (Agent 2)', provider: 'dialagram' },
};

function withTimeout(ms = 5000) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), ms);
    return { signal: controller.signal, done: () => clearTimeout(timeout) };
}

function normalizeOllamaModel(model) {
    const name = model?.name || model?.model;
    if (!name || name.includes(':cloud') || model.remote_model || model.remote_host) return null;
    return {
        ...model,
        id: name,
        name,
        provider: 'ollama'
    };
}

function isDialagramModel(modelId) {
    return Object.values(MODELS).some(model => model.id === modelId)
        || Object.values(DEWAN_MODELS).some(model => model.id === modelId);
}

function estimateTokens(text = '') {
    if (!text) return 0;
    return Math.max(1, Math.ceil(String(text).length / 4));
}

function cleanHistoryContent(message) {
    if (typeof message?.text === 'string') return message.text;
    if (message?.text?.synthesis) return message.text.synthesis;
    if (message?.text?.primary) return message.text.primary;
    return '';
}

function safeFileName(name = 'attachment.txt') {
    return String(name)
        .replace(/[\/\\?%*:|"<>]/g, '-')
        .replace(/\s+/g, ' ')
        .trim()
        .slice(0, 160) || 'attachment.txt';
}

function decodeBase64(data) {
    const clean = String(data || '').replace(/^data:[^,]+,/, '');
    return Buffer.from(clean, 'base64');
}

function extractText(buffer) {
    return buffer.toString('utf8').replace(/\u0000/g, '').trim();
}

async function readJson(file, fallback) {
    try {
        return JSON.parse(await fs.readFile(file, 'utf8'));
    } catch {
        return fallback;
    }
}

async function writeJson(file, value) {
    await fs.mkdir(path.dirname(file), { recursive: true });
    await fs.writeFile(file, JSON.stringify(value, null, 2));
}

function emptyTokenUsage() {
    return {
        totalTokens: 0,
        inputTokens: 0,
        outputTokens: 0,
        totalCost: 0,
        requests: 0,
        byProvider: {},
        byModel: {},
        lastUpdated: null
    };
}

async function recordTokenUsage({ provider, model, usage = {} }) {
    const promptTokens = Number(usage.promptTokens || usage.prompt_tokens || 0);
    const completionTokens = Number(usage.completionTokens || usage.completion_tokens || 0);
    const totalTokens = Number(usage.totalTokens || usage.total_tokens || promptTokens + completionTokens || 0);
    if (!totalTokens) return;

    const current = { ...emptyTokenUsage(), ...(await readJson(TOKEN_USAGE_FILE, emptyTokenUsage())) };
    current.inputTokens += promptTokens;
    current.outputTokens += completionTokens;
    current.totalTokens += totalTokens;
    current.totalCost += Number(usage.cost || 0);
    current.requests += 1;
    current.lastUpdated = new Date().toISOString();

    const providerKey = provider || 'unknown';
    const modelKey = model || 'unknown';
    current.byProvider[providerKey] = (current.byProvider[providerKey] || 0) + totalTokens;
    current.byModel[modelKey] = (current.byModel[modelKey] || 0) + totalTokens;

    await writeJson(TOKEN_USAGE_FILE, current);
}

async function stageFiles(files = []) {
    await fs.mkdir(UPLOADS_DIR, { recursive: true });
    const staged = [];
    const warnings = [];

    for (const file of files) {
        const name = safeFileName(file.name);
        const type = file.type || 'application/octet-stream';
        const buffer = decodeBase64(file.data);

        if (!buffer.length) {
            warnings.push(`${name}: empty file skipped`);
            continue;
        }

        if (buffer.length > MAX_STAGED_FILE_BYTES) {
            warnings.push(`${name}: file terlalu besar, batas ${(MAX_STAGED_FILE_BYTES / 1024 / 1024).toFixed(0)}MB`);
            continue;
        }

        const id = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
        const safeName = `${id}-${name}`;
        const filePath = path.join(UPLOADS_DIR, safeName);
        const manifestPath = path.join(UPLOADS_DIR, `${id}.json`);
        const rawText = extractText(buffer);
        const truncated = rawText.length > MAX_FILE_CONTEXT_CHARS;
        const content = truncated ? rawText.slice(0, MAX_FILE_CONTEXT_CHARS) : rawText;

        await fs.writeFile(filePath, buffer);
        await writeJson(manifestPath, {
            id,
            name,
            type,
            size: buffer.length,
            filePath,
            content,
            truncated,
            tokenEstimate: estimateTokens(content),
            createdAt: new Date().toISOString()
        });

        staged.push({
            id,
            name,
            type,
            size: buffer.length,
            tokenEstimate: estimateTokens(content),
            truncated
        });
    }

    return { files: staged, warnings };
}

async function buildAttachmentContext(attachments = []) {
    if (!Array.isArray(attachments) || attachments.length === 0) return '';

    const parts = [];
    for (const attachment of attachments) {
        const manifestPath = path.join(UPLOADS_DIR, `${attachment.id}.json`);
        const manifest = await readJson(manifestPath, null);
        if (!manifest) continue;

        parts.push([
            `--- ${manifest.name} ---`,
            `Stored temporarily on backend: ${manifest.filePath}`,
            manifest.truncated ? '[Note: file content truncated for context safety]' : '',
            manifest.content || '[No text content extracted]'
        ].filter(Boolean).join('\n'));
    }

    return parts.length ? `\n\n[Attached Files Processed By Backend]\n${parts.join('\n\n')}` : '';
}

async function cleanupAttachments(attachments = []) {
    await Promise.all((attachments || []).map(async attachment => {
        const manifestPath = path.join(UPLOADS_DIR, `${attachment.id}.json`);
        const manifest = await readJson(manifestPath, null);
        await Promise.all([
            manifest?.filePath ? fs.rm(manifest.filePath, { force: true }).catch(() => {}) : Promise.resolve(),
            fs.rm(manifestPath, { force: true }).catch(() => {})
        ]);
    }));
}

async function checkDialagram() {
    try {
        if (!API_CONFIG.dialagram.key) return false;
        const request = withTimeout(20000);
        
        const res = await fetch(`${API_CONFIG.dialagram.url}/chat/completions`, {
            method: 'POST',
            headers: { 
                'Authorization': `Bearer ${API_CONFIG.dialagram.key}`, 
                'Content-Type': 'application/json' 
            },
            body: JSON.stringify({ 
                model: 'qwen-3.6-plus', 
                messages: [{ role: 'user', content: 'ping' }],
                stream: false 
            }),
            signal: request.signal
        });
        
        request.done();
        return res.ok;
    } catch { return false; }
}

async function checkOpenCode() {
    try {
        const request = withTimeout(3000);
        const res = await fetch(`${OPENCODE_URL}/global/health`, { signal: request.signal });
        request.done();
        if (!res.ok) return false;
        const data = await res.json();
        return data.healthy === true;
    } catch { return false; }
}

async function checkOllamaLocal() {
    try {
        const request = withTimeout(3000);
        const res = await fetch(`${API_CONFIG.ollama.url}/api/tags`, { signal: request.signal });
        request.done();
        if (!res.ok) return false;
        const data = await res.json();
        return (data.models || [])
            .map(normalizeOllamaModel)
            .filter(Boolean);
    } catch { return false; }
}

async function callDialagram(model, prompt, history = []) {
    const messages = [
        { role: 'system', content: 'You are a helpful AI assistant.' },
        ...history.map(m => ({ 
            role: (m.role === 'AI' || m.role === 'assistant') ? 'assistant' : 'user', 
            content: typeof m.text === 'string' ? m.text : m.text.synthesis || '' 
        })),
        { role: 'user', content: prompt }
    ];

    // Longer timeout for thinking models
    const timeoutMs = model.includes('thinking') ? 120000 : 60000;

    try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), timeoutMs);

        const response = await fetch(`${API_CONFIG.dialagram.url}/chat/completions`, {
            method: 'POST',
            headers: { 
                'Authorization': `Bearer ${API_CONFIG.dialagram.key}`, 
                'Content-Type': 'application/json' 
            },
            body: JSON.stringify({ model, messages, stream: false }),
            signal: controller.signal
        });
        
        clearTimeout(timeout);
        
        if (!response.ok) {
            const err = await response.text();
            throw new Error(`API Error ${response.status}: ${err.substring(0, 200)}`);
        }
        
        const data = await response.json();
        const content = data.choices?.[0]?.message?.content || '';
        const usage = data.usage ? {
            promptTokens: data.usage.prompt_tokens,
            completionTokens: data.usage.completion_tokens,
            totalTokens: data.usage.total_tokens
        } : {
            promptTokens: estimateTokens(messages.map(m => m.content).join('\n')),
            completionTokens: estimateTokens(content)
        };
        return { success: true, content, usage };
    } catch (error) {
        if (error.name === 'AbortError') {
            return { success: false, error: 'Request timeout' };
        }
        return { success: false, error: error.message };
    }
}

async function callOllama(model, prompt, history = []) {
    const messages = [
        ...history.map(m => ({ 
            role: (m.role === 'AI' || m.role === 'assistant') ? 'assistant' : 'user', 
            content: cleanHistoryContent(m)
        })),
        { role: 'user', content: prompt }
    ];

    try {
        const request = withTimeout(600000);

        const response = await fetch(`${API_CONFIG.ollama.url}/api/chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ model, messages, stream: false, keep_alive: '10m' }),
            signal: request.signal
        });

        request.done();

        if (!response.ok) {
            const err = await response.text();
            throw new Error(`Ollama Error ${response.status}: ${err.substring(0, 200)}`);
        }

        const data = await response.json();
        const content = data.message?.content || '';
        return {
            success: true,
            content,
            usage: {
                promptTokens: data.prompt_eval_count || estimateTokens(messages.map(m => m.content).join('\n')),
                completionTokens: data.eval_count || estimateTokens(content),
                totalTokens: (data.prompt_eval_count || 0) + (data.eval_count || 0)
            }
        };
    } catch (error) {
        if (error.name === 'AbortError') {
            return { success: false, error: 'Ollama timeout after 10 minutes' };
        }
        return { success: false, error: error.message };
    }
}

async function resolveSelectedModel(modelId) {
    const selectedModel = modelId || MODELS.primary.id;

    if (selectedModel === 'opencode') {
        return { id: selectedModel, name: 'OpenCode (Local)', provider: 'opencode' };
    }

    if (isDialagramModel(selectedModel)) {
        return { id: selectedModel, name: selectedModel, provider: 'dialagram' };
    }

    const localModels = await checkOllamaLocal();
    const localModel = Array.isArray(localModels)
        ? localModels.find(model => model.id === selectedModel || model.name === selectedModel || model.model === selectedModel)
        : null;

    if (localModel) {
        return { id: localModel.id, name: `${localModel.name} (Local)`, provider: 'ollama' };
    }

    return { id: MODELS.primary.id, name: MODELS.primary.name, provider: 'dialagram' };
}

async function getProjects() {
    try { return JSON.parse(await fs.readFile(PROJECTS_FILE, 'utf8')); }
    catch { return []; }
}

async function saveProjects(projects) {
    await fs.writeFile(PROJECTS_FILE, JSON.stringify(projects, null, 2));
}

async function getChats() {
    try { return JSON.parse(await fs.readFile(CHATS_FILE, 'utf8')); }
    catch { return {}; }
}

async function saveChat(projectId, messages) {
    const chats = await getChats();
    chats[projectId || 'global'] = messages;
    await fs.writeFile(CHATS_FILE, JSON.stringify(chats, null, 2));
}

async function searchInternet(query) {
    try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 10000);
        const res = await fetch(`https://duckduckgo.com/html/?q=${encodeURIComponent(query)}`, {
            signal: controller.signal
        });
        clearTimeout(timeout);
        return (await res.text()).substring(0, 3000);
    } catch { return null; }
}

async function getTokenStats() {
    const usage = { ...emptyTokenUsage(), ...(await readJson(TOKEN_USAGE_FILE, emptyTokenUsage())) };
    const hasOnlyLocalUsage = usage.totalTokens > 0
        && Object.keys(usage.byProvider).length === 1
        && usage.byProvider.ollama;

    return {
        totalTokens: usage.totalTokens,
        inputTokens: usage.inputTokens,
        outputTokens: usage.outputTokens,
        requests: usage.requests,
        cost: usage.totalCost ? `$${usage.totalCost.toFixed(4)}` : '$0.00',
        remainingTokens: null,
        remainingLabel: hasOnlyLocalUsage ? 'local ∞' : 'sisa n/a',
        byProvider: usage.byProvider,
        byModel: usage.byModel,
        lastUpdated: usage.lastUpdated
    };
}

ipcMain.handle('ai:chat', async (event, body) => {
    const { message, displayMessage, attachments, useInternet, projectId, debateMode, history, selectedBrain } = body;

    const systemPrompt = `You are "Gemma", an AI assistant. Be helpful, concise and precise.`;

    try {
        const selectedModel = await resolveSelectedModel(selectedBrain);
        let context = useInternet ? await searchInternet(message) : '';
        const attachmentContext = await buildAttachmentContext(attachments);

        let fullPrompt = context 
            ? `${systemPrompt}\n\nWeb Context:\n${context}\n\nUser: ${message}${attachmentContext}`
            : `${systemPrompt}\n\nUser: ${message}${attachmentContext}`;

        let primaryResult;
        let providerAvailable = false;

        if (selectedModel.provider === 'ollama') {
            providerAvailable = true;
            primaryResult = await callOllama(selectedModel.id, fullPrompt, history);
        } else if (selectedModel.provider === 'opencode') {
            providerAvailable = await checkOpenCode();
            primaryResult = providerAvailable
                ? { success: false, error: 'OpenCode chat bridge is detected, but direct prompt forwarding is not configured yet.' }
                : { success: false, error: 'OpenCode local agent unreachable' };
        } else {
            providerAvailable = await checkDialagram();
            primaryResult = providerAvailable
                ? await callDialagram(selectedModel.id, fullPrompt, history)
                : { success: false, error: 'Dialagram API unreachable' };
        }

        if (primaryResult.success) {
            await recordTokenUsage({
                provider: selectedModel.provider,
                model: selectedModel.id,
                usage: primaryResult.usage
            });
        }

        let secondaryResult = null;
        let DewanResult = null;

        if (debateMode && selectedModel.provider === 'dialagram' && providerAvailable) {
            const [agent1, agent2] = await Promise.all([
                callDialagram(DEWAN_MODELS.agent1.id, fullPrompt, history),
                callDialagram(DEWAN_MODELS.agent2.id, fullPrompt, history)
            ]);
            secondaryResult = agent1;
            DewanResult = agent2;
            if (agent1.success) await recordTokenUsage({ provider: 'dialagram', model: DEWAN_MODELS.agent1.id, usage: agent1.usage });
            if (agent2.success) await recordTokenUsage({ provider: 'dialagram', model: DEWAN_MODELS.agent2.id, usage: agent2.usage });
        }

        const primaryText = primaryResult.success ? primaryResult.content : `Error: ${primaryResult.error}`;
        
        const synthesis = primaryResult.success ? primaryResult.content : 'Provider failed';

        const responsePayload = {
            primary: primaryText,
            secondary: secondaryResult ? (secondaryResult.success ? secondaryResult.content : `Error: ${secondaryResult.error}`) : null,
            Dewan: DewanResult ? (DewanResult.success ? DewanResult.content : `Error: ${DewanResult.error}`) : null,
            synthesis: synthesis,
            debateMode: !!debateMode && selectedModel.provider === 'dialagram',
            model: selectedModel.name,
            provider: selectedModel.provider,
            models: debateMode && selectedModel.provider === 'dialagram' ? { primary: DEWAN_MODELS.agent1.name, Dewan: DEWAN_MODELS.agent2.name } : { primary: selectedModel.name },
            status: providerAvailable && primaryResult.success ? 'connected' : 'disconnected',
            usage: primaryResult.usage || null,
            warning: primaryResult.success ? null : `${selectedModel.name} gagal: ${primaryResult.error}`
        };

        const updatedHistory = [...(history || []), { role: 'user', text: displayMessage || message }, { role: 'assistant', text: responsePayload }];
        await saveChat(projectId, updatedHistory);
        await cleanupAttachments(attachments);

        return responsePayload;
    } catch (error) {
        await cleanupAttachments(attachments);
        throw new Error(error.message);
    }
});

ipcMain.handle('ai:getStatus', async () => {
    const [dialagram, opencode, localModels] = await Promise.all([
        checkDialagram(),
        checkOpenCode(),
        checkOllamaLocal()
    ]);
    
    return { dialagram, opencode, localModels: Array.isArray(localModels) ? localModels : [] };
});

ipcMain.handle('ai:getModels', async () => {
    const [localModels, opencodeAvailable] = await Promise.all([
        checkOllamaLocal(),
        checkOpenCode()
    ]);

    return {
        dialagram: Object.values(MODELS),
        DewanModels: Object.values(DEWAN_MODELS),
        localModels: Array.isArray(localModels) ? localModels : [],
        opencodeAvailable
    };
});

ipcMain.handle('ai:getApiConfig', async () => {
    return {
        dialagram: { key: API_CONFIG.dialagram.key ? '***' + API_CONFIG.dialagram.key.slice(-4) : '', hasKey: !!API_CONFIG.dialagram.key },
        openai: { key: API_CONFIG.openai.key ? '***' + API_CONFIG.openai.key.slice(-4) : '', hasKey: !!API_CONFIG.openai.key },
        openrouter: { key: API_CONFIG.openrouter.key ? '***' + API_CONFIG.openrouter.key.slice(-4) : '', hasKey: !!API_CONFIG.openrouter.key }
    };
});

ipcMain.handle('ai:setApiConfig', async (event, { provider, key }) => {
    if (API_CONFIG[provider]) {
        API_CONFIG[provider].key = key;
        await saveConfig();
        return { success: true };
    }
    return { success: false, error: 'Unknown provider' };
});

ipcMain.handle('ai:getTokenStats', async () => getTokenStats());

ipcMain.handle('ai:getChat', async (event, { projectId }) => (await getChats())[projectId] || []);

ipcMain.handle('ai:getProjects', async () => getProjects());

ipcMain.handle('ai:addProject', async (event, { name, path: projectPath }) => {
    const projects = await getProjects();
    const newProject = { id: Date.now().toString(), name, path: projectPath };
    projects.push(newProject);
    await saveProjects(projects);
    return { success: true, projects };
});

ipcMain.handle('ai:deleteProject', async (event, { projectId }) => {
    const projects = await getProjects().then(ps => ps.filter(p => p.id !== projectId));
    await saveProjects(projects);
    return { success: true, projects };
});

ipcMain.handle('fs:stageFiles', async (event, { files }) => stageFiles(files));

ipcMain.handle('fs:listFiles', async (event, { path: targetPath }) => {
    try {
        const files = await fs.readdir(targetPath || process.cwd(), { withFileTypes: true });
        return { files: files.map(f => ({ name: f.name, isDirectory: f.isDirectory() })) };
    } catch (error) { throw new Error(error.message); }
});

ipcMain.handle('fs:readFile', async (event, { filePath }) => {
    try { return { content: await fs.readFile(filePath, 'utf8') }; }
    catch (error) { throw new Error(error.message); }
});

ipcMain.handle('fs:writeFile', async (event, { filePath, content }) => {
    try { await fs.writeFile(filePath, content, 'utf8'); return { success: true }; }
    catch (error) { throw new Error(error.message); }
});

ipcMain.handle('clipboard:write', async (event, text) => {
    clipboard.writeText(text);
    return true;
});

ipcMain.handle('clipboard:read', async () => {
    return clipboard.readText();
});

ipcMain.handle('dialog:openDirectory', async () => {
    try {
        const { canceled, filePaths } = await dialog.showOpenDialog({ properties: ['openDirectory'] });
        return canceled ? null : filePaths[0];
    } catch { return null; }
});

ipcMain.handle('window:minimize', () => mainWindow?.minimize());
ipcMain.handle('window:maximize', () => {
    if (mainWindow?.isMaximized()) {
        mainWindow.unmaximize();
    } else {
        mainWindow?.maximize();
    }
});
ipcMain.handle('window:close', () => mainWindow?.close());

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        frame: true,
        backgroundColor: '#1a1a2e',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js'),
        },
        title: "Qwen Unleashed"
    });

    mainWindow.center();

    const menu = Menu.buildFromTemplate([
        {
            label: 'Edit',
            submenu: [
                { role: 'undo' },
                { role: 'redo' },
                { type: 'separator' },
                { role: 'cut' },
                { role: 'copy' },
                { role: 'paste' },
                { role: 'selectAll' }
            ]
        },
        {
            label: 'View',
            submenu: [
                { role: 'reload' },
                { role: 'toggleDevTools' },
                { type: 'separator' },
                { role: 'resetZoom' },
                { role: 'zoomIn' },
                { role: 'zoomOut' },
                { type: 'separator' },
                { role: 'togglefullscreen' }
            ]
        },
        {
            label: 'Window',
            submenu: [
                { role: 'minimize' },
                { role: 'zoom' },
                { role: 'close' }
            ]
        }
    ]);
    Menu.setApplicationMenu(menu);

    mainWindow.loadFile(path.join(__dirname, 'public', 'index.html'));
    return mainWindow;
}

app.whenReady().then(async () => {
    await loadConfig();
    createWindow();
    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit();
});
